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
fParams = fParamsAll.v3;                      % Frequency Parameters
iParams = iParamsAll.MIMO_SAR;                % Scanning Parameters
p = pAll.Grid3D;                              % Reflectivity Function p(x,y,z)
clear fParamsAll iParamsAll pAll

%% 3. Get the MIMO Echo Signal sarData = s(x,k)
%-------------------------------------------------------------------------%
% Scanning is performed in the horizontal domain only using MIMO
% transceiver
sarDataY = SAR_1D_createEcho_MIMO(iParams,fParams,p);

%% 4. Perform Phase Correction
%-------------------------------------------------------------------------%
sarDataYPC = phaseCorrection(sarDataY,iParams,fParams);

%% 5. Reconstruct the 2D Image using the Range Migration Algorithm (RMA)
%-------------------------------------------------------------------------%
sarImageY_2D_RMA = SAR_1D_reconstructImage_2D_RMA_MIMO(sarDataYPC,iParams,fParams);

%% 6. Reconstruct the 2D Image using the Back Projection Algorithm (BPA)

sarImageY_2D_BPA = SAR_1D_reconstructImage_2D_BPA_MIMO(sarDataYPC,iParams,fParams,p);

%% 7. Reconstruct the 2D Image using the Matched Filter (MF) Technique

sarImageY_2D_MF = SAR_1D_reconstructImage_2D_MF_MIMO(sarDataYPC,iParams,fParams,p);