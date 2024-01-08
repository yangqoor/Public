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
iParams.nTx = 1;
iParams.nRx = 4;
iParams.nAngMeasurement = 1200;
iParams.nVerMeasurement = 512;
iParams.nFFT = 512;
iParams.xyzSizeT_m = 0.5; % m
iParams.tStepM_deg = 360/iParams.nAngMeasurement; % deg
iParams.lambda_mm = 299792458/(79e9)*1e3; % mm
iParams.yStepM_mm = iParams.lambda_mm/4; % mm
iParams.R0_mm = 250; % mm
iParams.scanName = "rotatorTest13";
iParams.CSAR = true;
iParams.MIMO = false;

%% Load in the data
%-------------------------------------------------------------------------%
rawData4D = dataReadTSW(iParams,fParams);

%% Save the Raw Data
%-------------------------------------------------------------------------%
save("./TSW Data/" + iParams.scanName,"rawData4D","iParams","fParams","-v7.3")

%% Look at Phase Profile
%-------------------------------------------------------------------------%
rangePeakData = phaseProfile(rawData4D,iParams,fParams);

%% Take Certain Frames
%-------------------------------------------------------------------------%
iParams.nAngMeasurement = 1000;
iParams.tStepM_deg = 360/iParams.nAngMeasurement; % deg
rawData4D = rawData4D(109:1108,:,:,:);

%% Try to Correct Bias
correctedData4D = phaseCalibration(rawData4D,iParams,fParams);
correctedData4D_1 = correctedData4D(:,:,1,:);
correctedData3D = data4Dto3D(correctedData4D_1,iParams,fParams);

%% Try to reconstruct the image
iParams.nFFT = 512;
iParams.PFA = 'linear';
iParams.xU = 2;
iParams.yU = 1;
iParams.zU = 2;
iParams.xyzSizeT_m = 0.5; % m
iParams.resize = false;
[csarImage,x,y,z] = CSAR_2D_reconstructImage_3D_PFA_JWS(correctedData3D,iParams,fParams);

%% Save the Image
%-------------------------------------------------------------------------%
save("./TSW Data/" + iParams.scanName,"csarImage","x","y","z","-append")

%% Create p

p.xLim = 400;
p.yLim = 400;
p.zLim = 400;

p.xMax = 0.1;
p.yMax = 0.3;
p.zMax = 0.1;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(-p.zMax+2*p.zMax/p.zLim,p.zMax,p.zLim);

%% Resize the Image

[rImage_SISO,x2,y2,z2] = resizeP(csarImage,x,y,z,p);

volumeViewer(rImage_SISO);

%% Saving the volumetric data

save knifeCSAR_SISO rImage_SISO config_SISO_VR config_SISO_MIP

%% Use volshow and configs
vr = figure('OuterPosition',[695 166 670 712]);
volshow(rImage_SISO,config_MIMO_VR);

mip = figure('OuterPosition',[695 166 670 712]);
volshow(rImage_SISO,config_MIMO_MIP);

%% Save Figures

saveas(vr,'./Real Images/knife_SISO_vr.jpg');
saveas(mip,'./Real Images/knife_SISO_mip.jpg');
