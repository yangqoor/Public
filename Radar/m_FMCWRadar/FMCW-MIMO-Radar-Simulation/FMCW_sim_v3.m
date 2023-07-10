clear; clc; close all
fname = '20220817_191142_00';
path = '/mnt/HDD04/Thesis_final/';
% fname = 'boulic_data_skel';
% path = 'C:\Users\emrek\Desktop\Technical\77ghz\FMCW Simulation\';
datapath = [path fname '.mat'];
load(datapath);
%% Radar parameters
c = physconst('LightSpeed'); %speed of light
BW = 4e9; %bandwidth
start_freq = 77e9;
end_freq = start_freq + BW;
fc = (start_freq + end_freq)/2; % carrier frequency
numADC = 256; % # of adc samples
% numChirps = 256; % # of chirps per frame
% numCPI = 10;
NPpF = 256;
frameDuration = 20e-3; % 40e-3
T = frameDuration/NPpF; % PRI
PRF = 1/T;
F = numADC/T; % sampling frequency
dt = 1/F; % sampling interval
slope = BW/T;
lambda = c/fc;
% N = numChirps*numADC*numCPI; % total # of adc samples
% t = linspace(0,T*numChirps*numCPI,N); % time axis, one frame
% t= 0:dt:dt*numADC*numChirps-dt;
t_onePulse = 0:dt:dt*numADC-dt;
% t_onePulse = dt:dt:dt*numADC;
% t_onePulse = linspace(0, T, numADC);
numTX = 1;
numRX = 4;
Vmax = lambda/(T*4); % Max Unamb velocity m/s
DFmax = 1/2*PRF; % = Vmax/(c/fc/2); % Max Unamb Dopp Freq
dR = c/(2*BW); % range resol
Rmax = F*c/(2*slope); % TI's MIMO Radar doc
Rmax2 = c/2/PRF; % lecture 2.3
% dV = lambda/(2*numChirps*T); % velocity resol, lambda/(2*framePeriod)
d_rx = lambda/2; % dist. between rxs
d_tx = 4*d_rx; % dist. between txs

% N_Dopp = numChirps; % length of doppler FFT
N_range = numADC; % length of range FFT
N_azimuth = numTX*numRX;
R = 0:dR:Rmax-dR; % range axis
% V = linspace(-Vmax, Vmax, numChirps); % Velocity axis
ang_ax = -90:90; % angle axis

%% Antennas
radar_loc_bias = -[10,0,2];
tx_loc = cell(1,numTX);
for i = 1:numTX
   tx_loc{i} = [(i-1)*d_tx 0 0] + radar_loc_bias;
%    scatter3(tx_loc{i}(1),tx_loc{i}(2),tx_loc{i}(3),'b','filled')
%    hold on
end

rx_loc = cell(1,numRX);
for i = 1:numRX
   rx_loc{i} = [tx_loc{numTX}(1)+d_tx+(i-1)*d_rx 0 0] + radar_loc_bias;
%    scatter3(rx_loc{i}(1),rx_loc{i}(2),rx_loc{i}(3),'r','filled')
end

%% Targets
fps_skel = 30; % 30
target_id = 22;
% skel_hist = skel_hist(target_id, :, :);
num_tar = size(skel_hist,1);
durationx = size(skel_hist,3)/fps_skel;
numChirps = floor(durationx*NPpF*(1/frameDuration));
tar_loc = zeros(num_tar, size(skel_hist,2), numChirps);
vel_hist = zeros(num_tar, size(skel_hist,2));

for t = 1:num_tar
    for i = 1:size(skel_hist,2)
        tar_loc(t,i,:) = spline(1:size(skel_hist,3), squeeze(skel_hist(t,i,:)), linspace(1,size(skel_hist,3), numChirps));      
%         tar_loc(t,i,:) = makima(1:size(skel_hist,3), squeeze(skel_hist(t,i,:)), linspace(1,size(skel_hist,3), numChirps));      
        vel_hist(t,i) = (max(tar_loc(t,i,:)) - min(tar_loc(t,i,:))) * sqrt(3) / durationx;
    end
end
% tar_loc = tar_loc+2;
tt = squeeze(tar_loc(1,3,:));
v_avg = mean(vel_hist,2);
% v_avg = (max(tar_loc(1,2,:)) - min(tar_loc(1,2,:))) * sqrt(3) / durationx;

% figure
% hold on
% t = 2;
% for i = 1:numADC*10:numChirps*numADC
%    scatter3(tar_loc(t,1,i), tar_loc(t,2,i), tar_loc(t,3,i))
% end

%% Elipsoid model

% figure('visible','off')
% cnt = 1;
% for n = 1:ceil(numChirps/size(skel_hist,3)):numChirps
%     disp(['Frame ' int2str(n) '/' int2str(numChirps)]);
%     create_body_model(squeeze(tar_loc(:,:,n)).');
%     title(['Elipsoid model, Chirp: ' int2str(n) '/' int2str(numChirps)]);
%     F2(cnt) = getframe(gcf); % gcf returns the current figure handle
%     cnt = cnt + 1;
% end
% 
% writerObj = VideoWriter([fname '.avi']);
% writerObj.FrameRate = fps_skel;
% open(writerObj);
% 
% for i=1:length(F2)
%         frame = F2(i) ;
%         writeVideo(writerObj, frame);
% end
% close(writerObj);

%% TX
delays_targets = cell(numTX,numRX,num_tar);

for t = 1:num_tar
    for i = 1:numTX
        for j = 1:numRX
            delays_targets{i,j,t} = (vecnorm(squeeze(tar_loc(t,:,:))-repmat(rx_loc{j},size(tar_loc,3),1).',2,1)+vecnorm(squeeze(tar_loc(t,:,:))-repmat(tx_loc{i},size(tar_loc,3),1).',2,1))/c;
%             delays_targets{i,j,t} = delays_targets{i,j,t}(1:1:end);
        end
    end
end
dd=delays_targets{1};
numChirps = length(dd);
%% Complex signal
phase = @(tx,fx) 2*pi*(fx.*tx+slope/2*tx.^2); % transmitted
phase2 = @(tx,fx,r,v) 2*pi*(2*fx*r/c+tx.*(2*fx*v/c + 2*slope*r/c)); % downconverted

phase_t = phase(t_onePulse,fc);

mixed = zeros(numTX,numRX,numChirps*numADC);
% new_mixed = zeros(numTX, numRX, numADC, numChirps);
for i = 1:numTX
    for j = 1:numRX
        disp(['Processing Channel: ' num2str(j) '/' num2str(numRX)]);
        for t = 1:num_tar
            disp([int2str(t) '/' int2str(num_tar)]);
            
            for k = 1:numChirps
                phase_tar = phase(t_onePulse-delays_targets{i,j,t}(k),fc); % received
                signal_tar((k-1)*numADC+1:k*numADC) = exp(1j*(phase_t - phase_tar));
%                 signal_tar = exp(1j*2*pi*...
%                     (pdist([squeeze(tar_loc(t,:,k));rx_loc{j}])+pdist([squeeze(tar_loc(t,:,k));tx_loc{i}]))/lambda);
%                 new_mixed(i,j,:,k) = squeeze(new_mixed(i,j,:,k)) + signal_tar;
            end
            mixed(i,j,:) = squeeze(mixed(i,j,:)) + signal_tar.';
%             break
        end
    end
end

% figure
% subplot(3,1,1)
% p1 = plot(t, real(signal_t));
% title('TX')
% xlim([0 0.1e-4])
% xlabel('Time (sec)');
% ylabel('Amplitude');
% subplot(3,1,2)
% p2 = plot(t, real(signal_1));
% title('RX')
% xlim([0 0.1e-4])
% xlabel('Time (sec)');
% ylabel('Amplitude');
% subplot(3,1,3)
% p3 = plot(t,real(mixed{i,j}));
% title('Mixed')
% xlim([0 0.1e-4])
% xlabel('Time (sec)');
% ylabel('Amplitude');

%% Post processing - 2-D FFT
% 
% RDC = reshape(cat(3,mixed{:}),numADC,numChirps*numCPI,numRX*numTX); % radar data cube
% RDC = reshape(mixed,numADC,numChirps,numRX*numTX);
RDC = reshape(mixed,numTX*numRX,numADC,numChirps);
RDC = permute(RDC, [2 3 1]);
numCPI = floor(numChirps/NPpF);
RDMs = zeros(numADC,NPpF,numTX*numRX,numCPI);
for i = 1:numCPI
    RD_frame = RDC(:,(i-1)*NPpF+1:i*NPpF,:);
    RDMs(:,:,:,i) = fftshift(fft2(RD_frame,[],[]),2);
end
% 
% figure
% colormap(jet(256))
% for f = 1:numCPI
%     imagesc([-Vmax Vmax], [0 Rmax], 20*log10(abs(RDMs(:,:,1,f))/max(max(abs(RDMs(:,:,1,f))))));
%     clim = get(gca,'clim');
%     caxis([clim(1)/2 0])
% %     title(['Frame ' int2str(f) '/' int2str(numCPI)]);
%     xlabel('Velocity (m/s)');
%     ylabel('Range (m)');
%     title(['Range-Doppler Map, Frame: ' int2str(f) '/' int2str(numCPI)]);
%     drawnow;
%     F2(f) = getframe(gcf); % gcf returns the current figure handle
%     pause(frameDuration)
% end
% 
% writerObj = VideoWriter('test.avi');
% writerObj.FrameRate = floor(1/frameDuration);
% open(writerObj);
% 
% for i=1:length(F2)
%         frame = F2(i) ;
%         writeVideo(writerObj, frame);
% end
% close(writerObj);
        
%% Micro-Doppler spectrogram

rBin = 1:256;
nfft = 2^12;window = 256;noverlap = 200;shift = window - noverlap;
% nfft = 2^12;window = 1024;noverlap = 1000;shift = window - noverlap;
sx = myspecgramnew(sum(fft(squeeze(RDC(rBin,:,1)))),window,nfft,shift); % mti filter and IQ correction
% sx = spectrogram(sum(fft(RDC(rBin,:,:))), window, noverlap, nfft);
% sx = myspecgramnew(sum(new_mixed(rBin,:)),window,nfft,shift); % mti filter and IQ correction
sx2 = abs(flipud(fftshift(sx,1)));
timeAxis = (1:numCPI)*frameDuration; % Time
freqAxis = linspace(-PRF/2,PRF/2,nfft); % Frequency Axis
fig = figure('visible','on');
colormap(jet(256));
% set(gca,'units','normalized','outerposition',[0,0,1,1]);
doppSignMTI = imagesc(timeAxis,[-PRF/2 PRF/2],20*log10(abs(sx2/max(sx2(:)))));
%     axis xy
%     set(gca,'FontSize',10)
title('micro-Doppler Spectrogram');
%     title(fOut(end-22:end-4))
xlabel('Time (sec)');
ylabel('Frequency (Hz)');
caxis([-45 0]) % 40
set(gca, 'YDir','normal')
set(gcf,'color','w');
%     colorbar;
% axis([0 4 -PRF/2 PRF/2])
%     saveas(fig,[fOut(1:end-4) '.fig']);
% set(gca,'xtick',[],'ytick',[])
frame = frame2im(getframe(gca));
% imwrite(frame,[fname '.png']);
