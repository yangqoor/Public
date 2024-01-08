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
iParams = iParamsAll.SISO_CSAR;             % Image and Scanning Parameters (360deg of rotation)
p = pAll.CSAR_Grid3D;                       % Reflectivity p(x,y,z) parameters
clear fParamsAll iParamsAll pAll

%% 3. Get the SISO-CSAR Echo Signal s(theta,k,y): csarData
%-------------------------------------------------------------------------%
iParams.nAngMeasurement = 512;
iParams.tStepM_deg = 360/iParams.nAngMeasurement; % deg

iParams.showP = true;
iParams.nVerMeasurement = 512;
iParams.yStepM_mm = iParams.lambda_mm/4; % mm
csarData = CSAR_2D_createEcho_SISO(iParams,fParams,p);

%% 4. 3D Image Reconstruction using Polar Formatting Algorithm (PFA)
%-------------------------------------------------------------------------%
iParams.nFFT = 512;
iParams.xU = 2;
iParams.yU = 1;
iParams.zU = 2;
[csarImage3D_PFA,x,y,z] = CSAR_2D_reconstructImage_3D_PFA_JWS(csarData,iParams,fParams,p);

%% 5. PSF at each dimension
%-------------------------------------------------------------------------%
figure; subplot(131); mesh(z,x,abs(squeeze(csarImage3D_PFA(:,(end-1)/2,:))));
subplot(132);mesh(x,y,abs(squeeze(csarImage3D_PFA((end-1)/2,:,:))));
subplot(133);mesh(y,z,abs(squeeze(csarImage3D_PFA(:,:,(end-1)/2))));

%% 7. Back Projection Algorithm (BPA)
%-------------------------------------------------------------------------%
tic
csarImage3D_BPA = CSAR_2D_reconstructImage_3D_BPA_SISO(csarData,iParams,fParams,p);
toc