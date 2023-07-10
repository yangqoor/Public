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