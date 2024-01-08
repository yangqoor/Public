%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

%% Load iParamsAll
%-------------------------------------------------------------------------%
load("iParamsAll","iParamsAll")

%% Save new iParamsAll
%-------------------------------------------------------------------------%
save("iParamsAll","iParamsAll")

%% SISO-SAR
%-------------------------------------------------------------------------%
clear iParams
iParams.nTx = 1;
iParams.nRx = 1;
iParams.nHorMeasurement = 256;
iParams.nUsefulHorMeasurement = 256;
iParams.nVerMeasurement = 256;
iParams.nFFT = 512;
iParams.xySizeT_m = -1; % m
iParams.xStepM_mm = 1; % mm
iParams.lambda_mm = 299792458/(79e9)*1e3; % mm
iParams.yStepM_mm = 1; % mm
iParams.z0_mm = 500; % mm
iParams.scanName = "SISO-SAR";
iParams.CSAR = false;
iParams.MIMO = false;

iParamsAll.SISO_SAR = iParams

%% SISO-CSAR
%-------------------------------------------------------------------------%
clear iParams
iParams.nTx = 1;
iParams.nRx = 1; 
iParams.nAngMeasurement = 512;
iParams.nVerMeasurement = 256;
iParams.nFFT = 512;
iParams.xySizeT_m = -1; % m
iParams.tStepM_deg = 360/iParams.nAngMeasurement; % deg
iParams.lambda_mm = 299792458/(79e9)*1e3; % mm
iParams.yStepM_mm = 1; % mm
iParams.R0_mm = 500; % mm
iParams.scanName = "SISO-CSAR";
iParams.CSAR = true;
iParams.MIMO = false;

iParamsAll.SISO_CSAR = iParams

%% MIMO-SAR
%-------------------------------------------------------------------------%
clear iParams
iParams.nTx = 2;
iParams.nRx = 4;
iParams.nHorMeasurement = 256;
iParams.nUsefulHorMeasurement = 256;
iParams.nVerMeasurement = 32;
iParams.nFFT = 512;
iParams.xyzSizeT_m = -1; % m
iParams.xStepM_mm = 1; % mm
iParams.lambda_mm = 299792458/(79e9)*1e3; % mm
iParams.yStepM_mm = iParams.lambda_mm/4; % mm
iParams.z0_mm = 500; % mm
iParams.scanName = "MIMO-SAR";
iParams.CSAR = false;
iParams.MIMO = true;

iParamsAll.MIMO_SAR = iParams

%% MIMO-CSAR
%-------------------------------------------------------------------------%
clear iParams
iParams.nTx = 2;
iParams.nRx = 4;
iParams.nAngMeasurement = 512;
iParams.nVerMeasurement = 64;
iParams.nFFT = 512;
iParams.xyzSizeT_m = 0.4; % mm
iParams.tStepM_deg = 360/iParams.nAngMeasurement; % deg
iParams.lambda_mm = 299792458/(79e9)*1e3; % mm
iParams.yStepM_mm = iParams.lambda_mm/4; % mm
iParams.R0_mm = 500; % mm
iParams.scanName = "MIMO-CSAR";
iParams.CSAR = true;
iParams.MIMO = true;

iParamsAll.MIMO_CSAR = iParams