%% Radar Parameters
% clear all;
clc;
close all;
load("Human_Walking_Data.mat");
t = 4; % 4s sampling
rv = 1;
rlc = 1.346*sqrt(rv); % relative length of a cycle
dc = rlc/rv; % duration of a cycle
numcyc = 3;
T = dc*numcyc; % total time duration 
nt = 2048; % sampling times per second
lambda = 0.15; % wave length
rangeres = 0.075; % range resolution
radarloc = [3,0,1.5]; % radar location
nr = round(2*sqrt(radarloc(1)^2+radarloc(2)^2+radarloc(3)^2)/rangeres);
np = t*nt;
j = sqrt(-1);

%% Display Range Profiles
figure
colormap(parula(256))
imagesc([1,np],[0,nr*rangeres],20*log10(abs(data)+eps))
xlabel('Time(s)×2048')
ylabel('Range (m)')
title('Range-Time Map')
axis xy
clim = get(gca,'CLim');
set(gca,'CLim',clim(2) + [-40 0]);
colorbar;
drawnow;

%% Micro-Doppler Signature
x = sum(data); % average over range cells
dT = T/np;
F = 1/dT; % np/T;

wd = 1024;
wdd2 = wd/2;
wdd8 = wd/8;
ns = np/wd;

%% Calculate Time-Frequency Micro-Doppler Signature
disp('Calculating segments of TF distribution ...')
for k = 1:ns
    disp(strcat('  segment progress: ',num2str(k),'/',num2str(round(ns))))
    sig(1:wd,1) = x(1,(k-1)*wd+1:(k-1)*wd+wd);
    TMP = stft(sig,16);
    TF2(:,(k-1)*wdd8+1:(k-1)*wdd8+wdd8) = TMP(:,1:8:wd);
end
TF = TF2;
disp('Calculating shifted segments of TF distribution ...')
TF1 = zeros(size(TF));
for k = 1:ns-1
    disp(strcat('  shift progress: ',num2str(k),'/',num2str(round(ns-1))))
    sig(1:wd,1) = x(1,(k-1)*wd+1+wdd2:(k-1)*wd+wd+wdd2);
    TMP = stft(sig,16);
    TF1(:,(k-1)*wdd8+1:(k-1)*wdd8+wdd8) = TMP(:,1:8:wd);
end
disp('Removing edge effects ...')
for k = 1:ns-1
    TF(:,k*wdd8-8:k*wdd8+8) = ...
        TF1(:,(k-1)*wdd8+wdd8/2-8:(k-1)*wdd8+wdd8/2+8);
end

%% Display Final Time-Frequency Signature

figure
colormap(parula(256))
% imagesc([0,T],[-F/2,F/2],20*log10(fftshift(abs(TF),1)+eps))
Doppler_Data_Formal = 20*log10(fftshift(abs(TF),1)+eps);
[Doppler_Data_Formal_Line,~] = size(Doppler_Data_Formal);
Doppler_Data = Doppler_Data_Formal(Doppler_Data_Formal_Line*13/32:Doppler_Data_Formal_Line*19/32,:);
imagesc([0,T],[-F/32,F/32],Doppler_Data);
xlabel('Time (s)')
ylabel('Doppler (Hz)')
title('Doppler-Time Map')
axis xy
clim = get(gca,'CLim');
set(gca,'CLim',clim(2) + [-45 0]);
colorbar;
drawnow;