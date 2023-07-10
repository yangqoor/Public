%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        fanalyzerTB.m
% Dependencies:    -
% 
% MATLAB v:        8.0.0 (R2012b)
% 
% Organization:    SAL
% Design by:       
% Feedback:                 
%                  ___
%
% License:         MIT
% 
% 
%  ADDITIONAL NOTES:
%  _________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

%Predefined variables
fs = 48000;
shortBufSize = 100;
normalBufSize = 2000;
longBufSize = 10000;

%Couple of sine waves
p0 = 0;
p1 = 0;
for(n = 1:normalBufSize)
    data0(n) = sin(p0);
    data1(n) = sin(p1);
    p0 = p0 + 0.01;
    p1 = p1 + 0.1;
end;

%Simple OPF for demonstration purposes
b = [1,0];
a = [1,-0.7];
data2 = zeros(1,shortBufSize);
data2(1) = 1;
data2 = filter(b,a,data2);

fa = fanalyzer(fs);

%% TimePlot... functions demonstration
fa.timePlot(data0, 'timePlot() demonstration');
fa.timePlotSamples(data0, 'timePlotSamples() demonstration');

%% Impulse response of filter using it coefficients
fa.impRespCoefs(b, a, 'impRespCoefs() demonstration');

%% Frequency response calculation functions
fa.freqResp(data2,'log','freqResp() demonstration');
%Frequency response using filter coefficients.
fa.freqRespCoefs(b,a,'freqRespCoefs() demonstration');

%% Phase response calculation functions
fa.phaseResp(data2,'log','phaseResp() demonstration');
%Phase response calculation function using filter coefs.
fa.phaseRespCoefs(b,a,'phaseRespCoefs() demonstration');

%% Phase and grop delay calculations
fa.phaseDelayCoefs(b,a,'log','phaseDelayCoefs() demonstration');
fa.groupDelayCoefs(b,a,'groupDelay() demonstration');

%% Pole/Zero plot usin filter coefficients demonstration
fa.pzPlotCoefs(b,a,'pzPlotCoefs() demonstration');

%% Polar complex frequency plot
fa.polarComplexFreqCoefs(b, a, 'polarComplexFreqCoefs() demonstration');

%% Spectrogram plotting
dataM(:,1) = data0;
dataM(:,2) = data1;
fa.spectrogram(dataM,'log','spectrogram() demonstration');

%% 3DSpectrogram
fa.spectrogram3D(data1,'spectrogram3D() demonstration',1024);
