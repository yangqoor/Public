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
iParams = iParamsAll.MIMO_CSAR;             % Image and Scanning Parameters (360deg of rotation)
clear fParamsAll iParamsAll pAll

%% Define the Reflectivity Function 
p.xLim = 64;
p.yLim = 64;
p.zLim = 64;

p.xMax = 0.15;
p.yMax = 0.25;
p.zMax = 0.15;

p.xT = linspace(-p.xMax+2*p.xMax/p.xLim,p.xMax,p.xLim);
p.yT = linspace(-p.yMax+2*p.yMax/p.yLim,p.yMax,p.yLim);
p.zT = linspace(-p.zMax+2*p.zMax/p.zLim,p.zMax,p.zLim);

p.pxyz = zeros(p.xLim,p.yLim,p.zLim);

% Diamond
p.pxyz(end/4,end/2,end/4) = 1;
p.pxyz(end/2,3*end/4,end/4) = 1;
p.pxyz(3*end/4,end/2,end/4) = 1;
p.pxyz(end/2,end/4,end/4) = 1;

% Middle Point
p.pxyz(end/2,end/2,end/2) = 1;

% Square
p.pxyz(end/4,end/4,3*end/4) = 1;
p.pxyz(end/4,3*end/4,3*end/4) = 1;
p.pxyz(3*end/4,end/4,3*end/4) = 1;
p.pxyz(3*end/4,3*end/4,3*end/4) = 1;

iParams.view = [-20,5];

CSAR_Grid3D_input = isoImageThreshold(p.pxyz,p.xT,p.yT,p.zT);
view(iParams.view)

%% 3. Get the MIMO-CSAR Echo Signal s(theta,k,y): csarData
%-------------------------------------------------------------------------%
iParams.showP = true;
iParams.nVerMeasurement = 64;
iParams.nAngMeasurement = 1000;
iParams.tStepM_deg = 360/iParams.nAngMeasurement; % deg
iParams.showP = false;
iParams.R0_mm = 250;
csarDataMIMO = CSAR_2D_createEcho_MIMO(iParams,fParams,p);

%% 5. Perform Phase Correction
%-------------------------------------------------------------------------%
csarDataMIMO_PC = phaseCorrection(csarDataMIMO,iParams,fParams);

%% Define a new p
p2.xLim = 256;
p2.yLim = 256;
p2.zLim = 256;

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
[csarImage3D_PFA,x,y,z] = CSAR_2D_reconstructImage_3D_PFA_JWS(csarDataMIMO_PC,iParams,fParams,p2);

%% Plot Recovered Image

CSAR_Grid3D_output = isoImageThreshold_dB(csarImage3D_PFA,-15,x,y,z);
view(iParams.view)

%% Save Files

save CSAR3D_Grid3D -v7.3

%% Save Image

save CSAR3D_Grid3D_Image csarImage3D_PFA x y z p

%% Save the Figures

saveas(CSAR_Grid3D_input,'CSAR_Grid3D_input.fig')
saveas(CSAR_Grid3D_input,'CSAR_Grid3D_input.jpg')

saveas(CSAR_Grid3D_output,'CSAR_Grid3D_output.fig')
saveas(CSAR_Grid3D_output,'CSAR_Grid3D_output.jpg')