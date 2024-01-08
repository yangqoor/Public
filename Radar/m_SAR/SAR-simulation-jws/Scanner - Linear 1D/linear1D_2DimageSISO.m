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
fParams = fParamsAll.v0;                      % Frequency Parameters
iParams = iParamsAll.SISO_SAR;                % Scanning Parameters
p = pAll.Grid3D;                              % Reflectivity Function p(x,y,z)
clear fParamsAll iParamsAll pAll

%% 3. Get the SISO Echo Signal sarData = s(x,k)
%-------------------------------------------------------------------------%
% Scanning is performed in the horizontal domain only using SISO
% transceiver
sarDataX = SAR_1D_createEcho_SISO(iParams,fParams,p);

%% 4. Reconstruct the 2D Image using Range Migration Algorithm (RMA)
%-------------------------------------------------------------------------%
sarImageX_2D_RMA = SAR_1D_reconstructImage_2D_RMA_SISO(sarDataX,iParams,fParams);

%% 5. Reconstruct the 2D Image using Back Projection Algorithm (BPA)
%-------------------------------------------------------------------------%
sarImageX_2D_BPA = SAR_1D_reconstructImage_2D_BPA_SISO(sarDataX,iParams,fParams,p);

%% 6. Reconstruct the 2D Image using Matched Filter Technique (MF)
%-------------------------------------------------------------------------%
sarImageX_2D_MF = SAR_1D_reconstructImage_2D_MF_SISO(sarDataX,iParams,fParams,p);