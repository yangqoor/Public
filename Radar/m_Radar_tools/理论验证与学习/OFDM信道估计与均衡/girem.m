% Function 4-4
% girem.m
%
% Function to remove guard interval from received signal
%
% Programmed by T.Yamamura and H.Harada
%

function [iout,qout]= girem(idata,qdata,fftlen2,gilen,nd);

%****************** variables *************************
% idata       : Input Ich data
% qdata       : Input Qch data
% iout        : Output Ich data
% qout        : Output Qch data
% fftlen2     : Length of FFT (points)
% gilen       : Length of guard interval (points)
% nd          : Number of OFDM symbols
% *****************************************************

idata2=reshape(idata,fftlen2,nd);
qdata2=reshape(qdata,fftlen2,nd);

iout=idata2(gilen+1:fftlen2,:);
qout=qdata2(gilen+1:fftlen2,:);

%******************** end of file ***************************
