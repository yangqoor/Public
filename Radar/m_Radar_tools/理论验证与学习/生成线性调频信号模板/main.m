clear;clc;
% 生成线性调频信号模板
%--------------------------------------------------------------------------
%   发射波形
%--------------------------------------------------------------------------
fs = 61.44e6;
bw = 20e6;
T = 131072.*1/fs;

waveform = phased.FMCWWaveform('SweepTime',T,...
                               'SweepBandwidth',bw,...
                               'SampleRate',fs,...
                               'SweepDirection','Up',...
                               'SweepInterval','Symmetric');
sig = waveform();