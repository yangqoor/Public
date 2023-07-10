%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Data Preprocessing
%雷达学报开源数据https://radars.ac.cn/web/data/getData?dataType=3DRIED
%Author：Wei Shunjun, Time：2020.6
%% 
clear
close all
clc
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Readrawdata
load('output_rawdata');
m = length(adcRawData.data);        % Number of Frame
num_TX = 1;                         % Number of transmitting antenna
num_RX = 4;                         % Number of receibing antenna
num_sample = 256;                   % Number of sampling points
Raw_echo = zeros(m*num_TX*num_RX,num_sample);
for ii = 1 : num_TX*m
    Raw_echo((ii-1)*4+1:ii*4,:) = squeeze(adcRawData.data{ii});
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Motion correction in Array plane
Num = num_TX*num_RX;                 % MIMO-Equivalent antenna
Nx = 407;                            % The sampling points in the horizontal direction
Nz = 200;                            % The sampling points in the vertical direction
Sr = Raw_echo(1:Num:end,:);          % Select echo data (1T1R)
Echo = zeros(Nx*Nz,num_sample);      % Echo of 1T1R
err = 43;                            % Number of movement error points
for ii = 1 : Nz
    kk = floor(ii/Nz*err);
    Echo((ii-1)*Nx+1:ii*Nx,:) = Sr((ii-1)*Nx+1+kk:ii*Nx+kk,:);
end
Echo = reshape(Echo,[Nx,Nz,num_sample]);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% System parameters
dx = 1;                               % Sampling distance at x (horizontal) axis in mm
dy = 2;                               % Sampling distance at y (vertical) axis in mm
nFFTspace = 512;                      % Number of FFT points for Spatial-FFT
c = physconst('lightspeed');
F0 = (77 + 1.8)*1e9;
Fs = 5*1e6;                           % Sampling rate (sps)
Ts = 1/Fs;                            % Sampling period
K = 70.295e12;                        % Slope const (Hz/sec)
tI = 6.2516e-10;                      % Instrument delay for range calibration
k = 2*pi*F0/c;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RMA Imaging
nFFTtime = num_sample;
Sr = fft(Echo,nFFTtime,3);                               % Range FFT
figure;imagesc(abs(reshape(Sr,[],nFFTtime)))
ID_select = 17;                                              
sarData = squeeze(Sr(:,:,ID_select)).';                  % Selecting echo data after pulse compression
R = c/2*(ID_select/(K*Ts*nFFTtime) - tI);
imSize = 400;                                            % Size of 2D image area in mm

for ii = 2:2:Nz
    sarData(ii,:) = fliplr(sarData(ii,:));
end

wSx = 2*pi/(dx*1e-3);                                    % Sampling frequency for Target Domain
kX = linspace(-(wSx/2),(wSx/2),nFFTspace);               % kX-Domain
wSy = 2*pi/(dy*1e-3);                                    % Sampling frequency for Target Domain
kY = (linspace(-(wSy/2),(wSy/2),nFFTspace)).';           % kY-Domain
K = single(sqrt((2*k).^2 - kX.^2 - kY.^2));
phaseFactor0 = exp(-1i*R*K);
phaseFactor0((kX.^2 + kY.^2) > (2*k).^2) = 0;
phaseFactor = K.*phaseFactor0;
phaseFactor = fftshift(fftshift(phaseFactor,1),2);
% Padding matrix with 0
[yPointM,xPointM] = size(sarData);
[yPointF,xPointF] = size(phaseFactor);
if (xPointF > xPointM)
    sarData = padarray(sarData,[0 floor((xPointF-xPointM)/2)],0,'pre');
    sarData = padarray(sarData,[0 ceil((xPointF-xPointM)/2)],0,'post');
else
    phaseFactor = padarray(phaseFactor,[0 floor((xPointM-xPointF)/2)],0,'pre');
    phaseFactor = padarray(phaseFactor,[0 ceil((xPointM-xPointF)/2)],0,'post');
end

if (yPointF > yPointM)
    sarData = padarray(sarData,[floor((yPointF-yPointM)/2) 0],0,'pre');
    sarData = padarray(sarData,[ceil((yPointF-yPointM)/2) 0],0,'post');
else
    phaseFactor = padarray(phaseFactor,[floor((yPointM-yPointF)/2) 0],0,'pre');
    phaseFactor = padarray(phaseFactor,[ceil((yPointM-yPointF)/2) 0],0,'post');
end

sarDataFFT = fft2(sarData,nFFTspace,nFFTspace);
sarImage_2DRMA = ifft2(sarDataFFT.*phaseFactor);

[yPointT,xPointT] = size(sarImage_2DRMA);
xRangeT = dx * (-(xPointT-1)/2 : (xPointT-1)/2)-50;
yRangeT = dy * (-(yPointT-1)/2 : (yPointT-1)/2)+120;
indXpartT = xRangeT>(-imSize/2) & xRangeT<(imSize/2);
indYpartT = yRangeT>(-imSize/2) & yRangeT<(imSize/2);
xRangeT = xRangeT(indXpartT);
yRangeT = yRangeT(indYpartT);
sarImage_2DFFT1 = abs(sarImage_2DRMA(indYpartT,indXpartT));
 
figure;imagesc(xRangeT,yRangeT,2*db(sarImage_2DFFT1/max(sarImage_2DFFT1(:))),[-40,0]);
axis equal xy off;colormap('jet');
title 'Sar Image-2D RMA'
