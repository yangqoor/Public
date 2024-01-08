%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

%% Add the Necessary Folders to Path (Run First)
%-------------------------------------------------------------------------%
addpath(genpath("../"))

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
iParams.nHorMeasurement = 900;
iParams.nUsefulHorMeasurement = 1000;
iParams.nVerMeasurement = 64;
iParams.nFFT = 512;
iParams.xyzSizeT_m = 0.5; % m
iParams.xStepM_mm = 0.5; % mm
iParams.lambda_mm = 299792458/(79e9)*1e3; % mm
iParams.yStepM_mm = iParams.lambda_mm/4; % mm
iParams.z0_mm = 250; % mm
iParams.scanName = "rectilinearTest2";
iParams.CSAR = false;
iParams.MIMO = true;

%% Load in the data
%-------------------------------------------------------------------------%
% size should be (8x64x1000x64)
rawData4D = dataReadTSW(iParams,fParams);
whos rawData4D

%% Save the Raw Data
%-------------------------------------------------------------------------%
save("./TSW Data/" + iParams.scanName,"rawData4D","iParams","fParams","-v7.3")

%% Look at Phase Profile
%-------------------------------------------------------------------------%
rangePeakData = phaseProfile(rawData4D,iParams,fParams);

%% Take Certain Frames
%-------------------------------------------------------------------------%
rawData4D = rawData4D(:,:,76:925,:);

%% Try to Correct Bias

correctedData3D = data4Dto3D(phaseCalibration(rawData4D,iParams,fParams),iParams,fParams);
correctedData3D = phaseCorrection(correctedData3D,iParams,fParams);

%% Try to reconstruct the image
iParams.nFFT = 1024;
iParams.RMA = 'linear';
iParams.xyzSizeT_m = 0.5; % m
iParams.resize = false;
[sarImage,x,y,z] = SAR_2D_reconstructImage_3D_RMA_MIMO(correctedData3D,iParams,fParams);
sarImage = flip(sarImage,3);

%% Save the Image
%-------------------------------------------------------------------------%
save("./TSW Data/" + iParams.scanName,"sarImage","x","y","z","-append")

%% Create p

p.xLim = 400;
p.yLim = 400;
p.zLim = 400;

p.xMax = 0.1;
p.yMax = 0.3;
p.zMax = 0.25;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(0.15,p.zMax-p.zMax/p.zLim,p.zLim);

%% Resize the Image

[rImage_MIMO,x2,y2,z2] = resizeP(sarImage,x,y,z,p);

volumeViewer(rImage_MIMO)

%% Saving the volumetric data

save knifeSAR_MIMO_Parallel rImage_MIMO configSAR_MIMO_VR configSAR_MIMO_MIP

%% Use volshow and configs
vr = figure('OuterPosition',[695 166 670 712]);
volshow(rImage_MIMO,configSAR_MIMO_VR);

mip = figure('OuterPosition',[695 166 670 712]);
volshow(rImage_MIMO,configSAR_MIMO_MIP);

%% Save Figures

saveas(vr,'./Real Images/knifeSAR_MIMO_Parallel_vr.jpg');
saveas(mip,'./Real Images/knifeSAR_MIMO_Parallel_mip.jpg');
