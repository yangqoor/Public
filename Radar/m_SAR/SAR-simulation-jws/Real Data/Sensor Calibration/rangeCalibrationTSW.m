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
iParams.nHorMeasurement = 1200;
iParams.nUsefulHorMeasurement = 1200;
iParams.nVerMeasurement = 2;
iParams.nFFT = 512;
iParams.xyzSizeT_m = -1; % m
iParams.xStepM_mm = 0.5; % mm
iParams.lambda_mm = 299792458/(79e9)*1e3; % mm
iParams.yStepM_mm = iParams.lambda_mm/4; % mm
iParams.z0_mm = 500; % mm
iParams.scanName = "rangeCalib3";
iParams.CSAR = false;
iParams.MIMO = true;

%% Load in the data
%-------------------------------------------------------------------------%
rawData4D = dataReadTSW(iParams,fParams);

%% Save the Raw Data
%-------------------------------------------------------------------------%
save("../TSW Data/" + iParams.scanName,"rawData4D","iParams","fParams")

%% Look at Phase Profile
%-------------------------------------------------------------------------%
rangePeakData = phaseProfile(rawData4D,iParams,fParams);

%% Calculate Range Data

rangeData3D = squeeze(fft(rawData4D(1,1,:,:),iParams.nFFT*8,4)).';

%% Get the Range Axis

rangeAxis = generateRangeAxis(fParams,iParams.nFFT*8);

%% Plot the Range Profile

figure; plot(rangeAxis,abs(rangeData3D));

[~,maxIdx] = max(rangeData3D,[],1);

maxIdx = mode(maxIdx);

expectedRange_mm = 250;
actualRange_mm = rangeAxis(maxIdx)*1e3;

%% Declare Range Bias Correction Factor

rangeBias_mm = expectedRange_mm - actualRange_mm;

save calData rangeBias_mm -append

%% Try to Correct Bias

correctedData3D = data4Dto3D(phaseCalibration(rawData4D,iParams,fParams),iParams,fParams);
rangecorData3D = squeeze(fft(correctedData3D(1,:,:),iParams.nFFT*8,3)).';

%% Plot the Range Profile

figure; plot(rangeAxis,abs(rangecorData3D));

[~,maxIdx] = max(rangecorData3D,[],1);

maxIdx = mode(maxIdx);

correctedRange_mm = rangeAxis(maxIdx)*1e3;
