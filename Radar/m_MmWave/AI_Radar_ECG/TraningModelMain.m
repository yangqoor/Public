% --------------------------------------------------------------------------------------------------
%
%           Demo software for AI Radar ECG
%                 
%
%            Release ver. 1.0  (Feb 10, 2025)
%
% --------------------------------------------------------------------------------------------
%
% All rights reserved.
% This work should be used for nonprofit purposes only.
% --------------------------------------------------------------------------------------------


clc;clear;close all;
fpath=cd;
addpath(fpath,"API");

%1D input: Radar Phase
radar_ecg_net_1

%3D input: Heartbeat sigal, output singal in level 3 and level 4 using Daubechies Wavelet
radar_ecg_net_3

%4D input: Radar Phase, Heartbeat sigal, output singal in level 3 and level 4 using Daubechies Wavelet
radar_ecg_net_4