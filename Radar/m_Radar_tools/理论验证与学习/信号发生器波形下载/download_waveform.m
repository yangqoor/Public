%--------------------------------------------------------------------------
%   通道一致性分析
%--------------------------------------------------------------------------
clear;clc;

%--------------------------------------------------------------------------
%   发射波形
%--------------------------------------------------------------------------
fc = 4.650e09;
fs = 61.44e6;
bw = 20e6;
T = 131072.*1/fs;

waveform = phased.FMCWWaveform('SweepTime',T,...
                               'SweepBandwidth',bw,...
                               'SampleRate',fs,...
                               'SweepDirection','Up',...
                               'SweepInterval','Symmetric');
sig = waveform();

%--------------------------------------------------------------------------
%   输出通道数据
%--------------------------------------------------------------------------
data = csvread('iladata.csv',1,0);

ch1_data_i = data(:,4);
ch1_data_q = data(:,5);
ch2_data_i = data(:,6);
ch2_data_q = data(:,7);

ch1_adc = ch1_data_i + 1j*ch1_data_q;
ch2_adc = ch2_data_i + 1j*ch2_data_q;

% figure(1)
% subplot(121);spectrogram(sig,128,64,128,fs,'yaxis')
% subplot(122);spectrogram(ch1_adc,128,64,128,fs,'yaxis')
TxSinkPara.IP = '192.168.1.53';
TxSinkPara.SampleRate = fs;
TxSinkPara.CenterFreq = fc;
TxSinkPara.Amplitude = 0;
TxSinkPara.FileName = 'WAVEFORM_20BW';
TxSinkPara.MinDuration = T;

TransmitWaveform(sig, TxSinkPara)
