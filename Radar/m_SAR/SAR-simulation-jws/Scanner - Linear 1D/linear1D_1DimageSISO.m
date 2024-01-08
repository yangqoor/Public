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
sarDataX = SAR_1D_createEcho_SISO(iParams,fParams,p);

%% 4. Construct the 1D Image from the Data at iParams.z0_mm
%-------------------------------------------------------------------------%
sarImageX_1D = SAR_1D_reconstructImage_1D_FFT_SISO(sarDataX,iParams,fParams);