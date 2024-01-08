%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

%% Load fParamsAll
%-------------------------------------------------------------------------%
load fParamsAll

%% Save new pAll
%-------------------------------------------------------------------------%
save fParamsAll

%% v0
%-------------------------------------------------------------------------%
fParamsAll.v0.K = 63.343e12;
fParamsAll.v0.fS = 9121e3;
fParamsAll.v0.adcSample = 512;
fParamsAll.v0.TXStartTime = 1e-6;
fParamsAll.v0.ADCStartTime = 6e-6;
fParamsAll.v0.RampEndTime = 63.14e-6;
fParamsAll.v0.f0 = 77e9;

%% v1
%-------------------------------------------------------------------------%
fParamsAll.v1.K = 63.343e12;
fParamsAll.v1.fS = 9121e3;
fParamsAll.v1.adcSample = 512;
fParamsAll.v1.TXStartTime = 1e-6;
fParamsAll.v1.ADCStartTime = 0;
fParamsAll.v1.RampEndTime = 63.14e-6;
fParamsAll.v1.f0 = 77e9;

%% v2
%-------------------------------------------------------------------------%
fParamsAll.v2.K = 19.988e12;
fParamsAll.v2.fS = 2572e3;
fParamsAll.v2.adcSample = 512;
fParamsAll.v2.TXStartTime = 1e-6;
fParamsAll.v2.ADCStartTime = 6e-6;
fParamsAll.v2.RampEndTime = 200.12e-6;
fParamsAll.v2.f0 = 77e9;

%% v3
%-------------------------------------------------------------------------%
fParamsAll.v3.K = 19.988e12;
fParamsAll.v3.fS = 322e3;
fParamsAll.v3.adcSample = 64;
fParamsAll.v3.TXStartTime = 1e-6;
fParamsAll.v3.ADCStartTime = 6e-6;
fParamsAll.v3.RampEndTime = 200.12e-6;
fParamsAll.v3.f0 = 77e9;