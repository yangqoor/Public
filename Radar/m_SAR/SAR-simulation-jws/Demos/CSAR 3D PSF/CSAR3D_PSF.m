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
clear fParamsAll iParamsAll pAll

%% Define Reflectivity Function
p.xLim = 256;
p.yLim = 256;
p.zLim = 256;

p.xMax = 0.3;
p.yMax = 0.2;
p.zMax = 0.3;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(-p.zMax+2*p.zMax/p.zLim,p.zMax,p.zLim);

p.pxyz = zeros(p.xLim,p.yLim,p.zLim);
p.pxyz(end/4,end/2,end/2) = 1;

iParams.view = [-80,10];

CSAR_PSF_input = isoImageThreshold(p.pxyz,p.xT,p.yT,p.zT);
xlim([p.zT(1)/4 p.zT(end)/4])
ylim([p.xT(1) p.xT(end)/4])
zlim([p.yT(1)/4 p.yT(end)/4])
view(iParams.view)

%% 3. Get the MIMO-CSAR Echo Signal s(theta,k,y): csarData
%-------------------------------------------------------------------------%
iParams.R0_mm = 250;
iParams.nVerMeasurement = 32;
iParams.nAngMeasurement = 1000;
iParams.tStepM_deg = 360/iParams.nAngMeasurement; % deg
iParams.showP = false;
csarDataMIMO = CSAR_2D_createEcho_MIMO(iParams,fParams,p);

%% 5. Perform Phase Correction
%-------------------------------------------------------------------------%
csarDataMIMO_PC = phaseCorrection(csarDataMIMO,iParams,fParams);

%% Define a new p
p2.xLim = 512;
p2.yLim = 512;
p2.zLim = 512;

p2.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p2.xLim);
p2.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p2.yLim);
p2.zT = linspace(-p.zMax+2*p.zMax/p.zLim,p.zMax,p2.zLim);

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
threshold_dB = -50;

xzData = squeeze(csarImage3D_PFA(:,end/2,:));
xzData = mag2db(xzData/max(xzData(:)));
xzData(xzData < threshold_dB) = threshold_dB;
CSAR_PSFxz = figure('OuterPosition',[695 166 670 712]); 
mesh(z,x,xzData,'FaceColor','interp','LineStyle','none');
xlabel("z(m)")
xlim([z(1) z(end)])
ylabel("x(m)")
ylim([x(1) x(end)])
colorbar
view(3)
set(CSAR_PSFxz.CurrentAxes,'FontSize',18);

xyData = squeeze(csarImage3D_PFA(:,:,end/2));
xyData = mag2db(xyData/max(xyData(:)));
xyData(xyData < threshold_dB) = threshold_dB;
CSAR_PSFxy = figure('OuterPosition',[695 166 670 712]);
mesh(y,x,xyData,'FaceColor','interp','LineStyle','none');
ylabel("x(m)")
ylim([x(1) x(end)])
xlabel("y(m)")
xlim([y(1) y(end)])
colorbar
view(3)
set(CSAR_PSFxy.CurrentAxes,'FontSize',18);

%%

yzData = squeeze(csarImage3D_PFA(end/4,:,:));
yzData = mag2db(yzData/max(yzData(:)));
yzData(yzData < -25) = -25;
CSAR_PSFyz = figure('OuterPosition',[695 166 670 712]);
mesh(y,z,yzData,'FaceColor','interp','LineStyle','none');
xlabel("y(m)")
xlim([y(1) y(end)])
ylabel("z(m)")
ylim([z(1) z(end)])
colorbar
view(2)
set(CSAR_PSFyz.CurrentAxes,'FontSize',18);

%% Plot Recovered Image

CSAR_PSF_output = isoImageThreshold_dB(csarImage3D_PFA,-10,x,y,z);
xlim([z(1)/4 z(end)/4])
ylim([x(1) x(end)/4])
zlim([y(1)/4 y(end)/4])
view(iParams.view)

%% Save Files

save CSAR3D_PSF -v7.3

%% Save Images

save CSAR3D_PSF_Image csarImage3D_PFA x y z p

%% Save Figures

% saveas(CSAR_PSF_input,'CSAR_PSF_input.fig')
% saveas(CSAR_PSF_input,'CSAR_PSF_input.jpg')
% saveas(CSAR_PSF_output,'CSAR_PSF_output.fig')
% saveas(CSAR_PSF_output,'CSAR_PSF_output.jpg')

% saveas(CSAR_PSFxy,'CSAR_PSFxy.fig')
saveas(CSAR_PSFxy,'CSAR_PSFxy_R0_250_DS_478.jpg')

% saveas(CSAR_PSFxz,'CSAR_PSFxz.fig')
saveas(CSAR_PSFxz,'CSAR_PSFxz_R0_250_DS_478.jpg')

%%
% saveas(CSAR_PSFyz,'CSAR_PSFyz.fig')
saveas(CSAR_PSFyz,'CSAR_PSFyz.jpg')