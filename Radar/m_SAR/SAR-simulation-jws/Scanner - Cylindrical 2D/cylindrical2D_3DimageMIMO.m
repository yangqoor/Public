%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

%% 1. Add the Necessary Folders to Path (Run First)
%-------------------------------------------------------------------------%
addpath(genpath("../"))

%% 2. Load iParams, fParams, and p
%-------------------------------------------------------------------------%
load fParamsAll; load iParamsAll; load pAll
fParams = fParamsAll.v3;                    % Frequency Parameters
iParams = iParamsAll.MIMO_CSAR;             % Image and Scanning Parameters (360deg of rotation)
p = pAll.CSAR_PSF;                       % Reflectivity p(x,y,z) parameters
clear fParamsAll iParamsAll pAll

%% 3. Get the MIMO-CSAR Echo Signal s(theta,k,y): csarData
%-------------------------------------------------------------------------%
iParams.showP = true;
iParams.nVerMeasurement = 64;
iParams.nAngMeasurement = 1000;
iParams.tStepM_deg = 360/iParams.nAngMeasurement; % deg
csarDataMIMO = CSAR_2D_createEcho_MIMO(iParams,fParams,p);

%% 5. Perform Phase Correction
%-------------------------------------------------------------------------%
csarDataMIMO_PC = phaseCorrection(csarDataMIMO,iParams,fParams);

%% 4. 3D Image Reconstruction using Polar Formatting Algorithm (PFA)
%-------------------------------------------------------------------------%
iParams.nFFT = 512;
iParams.PFA = 'linear';
iParams.xU = 2;
iParams.yU = 1;
iParams.zU = 2;
iParams.resize = true;
[csarImage3D_PFA,x,y,z] = CSAR_2D_reconstructImage_3D_PFA_JWS(csarDataMIMO_PC,iParams,fParams,p);

%% 6. PSF at each dimension
%-------------------------------------------------------------------------%
figure; subplot(131); mesh(z,x,abs(squeeze(csarImage3D_PFA(:,(end)/2,:))),'FaceColor','interp','LineStyle','none');
subplot(132);mesh(x,y,abs(squeeze(csarImage3D_PFA((end)/2,:,:))),'FaceColor','interp','LineStyle','none');
subplot(133);mesh(y,z,abs(squeeze(csarImage3D_PFA(:,:,(end)/2))),'FaceColor','interp','LineStyle','none');