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
p = pAll.CSAR_PSF_OC;                       % Reflectivity p(x,y,z) parameters
clear fParamsAll iParamsAll pAll

%% 3. Get the SISO-CSAR Echo Signal s(theta,k): csarData
%-------------------------------------------------------------------------%
iParams.showP = true;
iParams.nAngMeasurement = 1000;
iParams.tStepM_deg = 360/iParams.nAngMeasurement;
csarData = CSAR_1D_createEcho_SISO(iParams,fParams,p);

%% 4. 2D Image Reconstruction by Back Projection Algorithm (BPA)
%-------------------------------------------------------------------------%
iParams.isAmplitudeFactor = true;
[csarImage2D_BPA,xBPA,zBPA] = CSAR_1D_reconstructImage_2D_BPA(csarData,iParams,fParams,p);

%% 5. 2D Image Reconstruction Polar Formatting Algorithm (PFA)
%-------------------------------------------------------------------------%
iParams.nFFT = 2048;         % Size of FFT (Before Upsampling)
iParams.xzSizeT_m = 0.4;    % Expected Size of Target
iParams.xU = 4;             % x-axis Upsample Factor
iParams.zU = 4;             % z-axis Upsample Factor
[csarImage2D_PFA,xPFA,zPFA] = CSAR_1D_reconstructImage_2D_PFA(csarData,iParams,fParams);

%% 6. 2D Image Reconstruction Segmented Polar Formatting Algorithm (PFA)
%-------------------------------------------------------------------------%
iParams.nFFT = 1024;        % Size of FFT (Before Upsampling)
iParams.xzSizeT_m = 0.4;    % Expected Size of Target
iParams.xU = 4;             % x-axis Upsample Factor
iParams.zU = 4;             % z-axis Upsample Factor
[csarImage2D_SegmentedPFA,x,z] = CSAR_1D_reconstructImage_2D_SegmentedPFA(csarData,iParams,fParams);

%% Plot Range Profile
nFFTBins = 4096;
csarRangeData = fft(csarData,nFFTBins,2);
ra = generateRangeAxis(fParams,nFFTBins);
figure;mesh(ra,(1:512)/512*360,abs(csarRangeData))
view(0,0)