% Function 4-3
% giins.m
%
% Function to insert guard interval into transmission signal
%
% Programmed by T.Yamamura and H.Harada
%

function [iout,qout]= giins(idata,qdata,fftlen,gilen,nd);

%****************** variables *************************
% idata    : Input Ich data
% qdata    : Input Qch data
% iout     : Output Ich data
% qout     : Output Qch data
% fftlen   : Length of FFT (points)
% gilen    : Length of guard interval (points)
% *****************************************************

idata1=reshape(idata,fftlen,nd);
qdata1=reshape(qdata,fftlen,nd);
idata2=[idata1(fftlen-gilen+1:fftlen,:); idata1];
qdata2=[qdata1(fftlen-gilen+1:fftlen,:); qdata1];

iout=reshape(idata2,1,(fftlen+gilen)*nd);
qout=reshape(qdata2,1,(fftlen+gilen)*nd);

%******************** end of file ***************************