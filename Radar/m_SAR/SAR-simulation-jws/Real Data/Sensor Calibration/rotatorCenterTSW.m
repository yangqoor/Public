%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

%% Add the Necessary Folders to Path (Run First)
%-------------------------------------------------------------------------%
addpath(genpath("../../"))

%% 2. Load fParams,
%-------------------------------------------------------------------------%
load fParamsAll
fParams = fParamsAll.v3;                    % Frequency Parameters
clear fParamsAll 

%% MIMO-SAR
%-------------------------------------------------------------------------%
clear iParams
iParams.nTx = 2;
iParams.nRx = 4;
iParams.nHorMeasurement = 512;
iParams.nUsefulHorMeasurement = 512;
iParams.nVerMeasurement = 10;
iParams.nFFT = 512;
iParams.xyzSizeT_m = -1; % m
iParams.xStepM_mm = 0.5; % mm
iParams.lambda_mm = 299792458/(79e9)*1e3; % mm
iParams.yStepM_mm = iParams.lambda_mm/4; % mm
iParams.z0_mm = 500; % mm
iParams.scanName = "findCenter6";
iParams.CSAR = false;
iParams.MIMO = true;

%% Load in the data
%-------------------------------------------------------------------------%
iParams.isTwoDirectionScanning = false;
rawData4D = dataReadTSW(iParams,fParams);

%% Save the Raw Data
%-------------------------------------------------------------------------%
save("../TSW Data/" + iParams.scanName,"rawData4D","iParams","fParams")

%% Look at Phase Profile
%-------------------------------------------------------------------------%
rangePeakData = phaseProfile(rawData4D,iParams,fParams);

%% Get Simulated Data
%-------------------------------------------------------------------------%
load fParamsAll; load iParamsAll; load pAll
fParams = fParamsAll.v3;                      % Frequency Parameters
iParams2 = iParamsAll.MIMO_SAR;                % Scanning Parameters
p = pAll.PSF;                              % Reflectivity Function p(x,y,z)
clear fParamsAll iParamsAll pAll

iParams2.showP = false;
sarData_MIMO = SAR_2D_createEcho_MIMO(iParams2,fParams,p);
rawData4D_2 = reshape(sarData_MIMO,8,[],256,64);
rangePeakData_sim = phaseProfile(rawData4D_2,iParams2,fParams);

%% Generate Calibration Data and Save
%-------------------------------------------------------------------------%
rd_sim = rangePeakData_sim(129:136,128)./abs(rangePeakData_sim(129:136,128));
rd = rangePeakData(41:48,451)./abs(rangePeakData(1:8,431));

calData = reshape(rd_sim./rd,[],1);
% calData = reshape(1./rd,[],1);

save calData calData

%% Try To Calibrate
%-------------------------------------------------------------------------%
calibratedData4D = phaseCalibration(rawData4D);

%% Look at phase profile
%-------------------------------------------------------------------------%
phaseProfile(calibratedData4D,iParams,fParams);

%% Correct Phase
%-------------------------------------------------------------------------%
pcData3D = phaseCorrection(data4Dto3D(calibratedData4D,iParams,fParams),iParams,fParams);

pcData4D = data3Dto4D(pcData3D,iParams,fParams);

%% Look at phase profile
%-------------------------------------------------------------------------%
phaseProfile(pcData4D,iParams,fParams);

%% Reconstruct 3D Image
%-------------------------------------------------------------------------%
SAR_2D_reconstructImage_3D_RMA_MIMO(pcData3D,iParams,fParams);
