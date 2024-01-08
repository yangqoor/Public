%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

%% 1. Add the Necessary Folders to Path (Run First)
%-------------------------------------------------------------------------%
addpath(genpath("../../"))

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
iParams.xU = 1;             % x-axis Upsample Factor
iParams.zU = 1;             % z-axis Upsample Factor
[csarImage2D_PFA,xPFA,zPFA] = CSAR_1D_reconstructImage_2D_PFA(csarData,iParams,fParams);

%% 6. PSF at each dimension
%-------------------------------------------------------------------------%
threshold_dB = -80;
psfBPA = abs(csarImage2D_BPA);
psfBPA = mag2db(psfBPA/max(psfBPA(:)));
psfBPA(psfBPA < threshold_dB) = threshold_dB;
CSAR_PSF_BPA = figure('OuterPosition',[695 166 670 712]); 
mesh(zBPA,xBPA,psfBPA,'FaceColor','interp','LineStyle','none');
xlabel("z(m)")
xlim([zBPA(1) zBPA(end)])
ylabel("x(m)")
ylim([xBPA(1) xBPA(end)])
cbBPA = colorbar;
ylabel(cbBPA,'dB')
view(3)
title("PSF")
set(CSAR_PSF_BPA.CurrentAxes,'FontSize',18);

psfPFA = abs(csarImage2D_PFA);
psfPFA = mag2db(psfPFA/max(psfPFA(:)));
psfPFA(psfPFA < threshold_dB) = threshold_dB;
CSAR_PSF_PFA = figure('OuterPosition',[695 166 670 712]);
mesh(zPFA,xPFA,psfPFA,'FaceColor','interp','LineStyle','none');
xlabel("z(m)")
xlim([zPFA(1) zPFA(end)])
ylabel("x(m)")
ylim([xPFA(1) xPFA(end)])
cbPFA = colorbar;
ylabel(cbPFA,'dB')
view(3)
title("PSF")
set(CSAR_PSF_PFA.CurrentAxes,'FontSize',18);

%% Save Figures

saveas(CSAR_PSF_input,'CSAR_PSF_input.fig')
saveas(CSAR_PSF_input,'CSAR_PSF_input.jpg')
saveas(CSAR_PSF_output,'CSAR_PSF_output.fig')
saveas(CSAR_PSF_output,'CSAR_PSF_output.jpg')

saveas(CSAR_PSF_PFA,'CSAR_PSFxy.fig')
saveas(CSAR_PSF_PFA,'CSAR_PSFxy.jpg')

saveas(CSAR_PSF_BPA,'CSAR_PSFxz.fig')
saveas(CSAR_PSF_BPA,'CSAR_PSFxz.jpg')

saveas(CSAR_PSFyz,'CSAR_PSFyz.fig')
saveas(CSAR_PSFyz,'CSAR_PSFyz.jpg')