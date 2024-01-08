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
p = pAll.CSAR_Grid3D;                              % Reflectivity Function p(x,y,z)
clear fParamsAll iParamsAll pAll

%% 3. Get the SISO Echo Signal syxkSISO = s(y,x,k)
%-------------------------------------------------------------------------%
sarData_SISO = SAR_2D_createEcho_SISO(iParams,fParams,p);

%% 4. Reconstruct the 3D Image by Range Migration Algorithm (RMA)
%-------------------------------------------------------------------------%
iParams.mex = false;
sarImage_RMA = SAR_2D_reconstructImage_3D_RMA_MIMO(sarData_SISO,iParams,fParams);

%% 5. Reconstruct the 3D Image by Back Projection Algorithm (BPA)
%-------------------------------------------------------------------------%
sarImage_BPA = SAR_2D_reconstructImage_3D_BPA_MIMO(sarData_SISO,iParams,fParams,p);

%% 6. Reconstruct the 3D Image by Matched Filter FFT (MF) Technique
%-------------------------------------------------------------------------%
sarImage_MF = SAR_2D_reconstructImage_3D_MF_MIMO(sarData_SISO,iParams,fParams,p);