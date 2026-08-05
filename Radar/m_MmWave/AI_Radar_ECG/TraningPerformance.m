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


load('TraninedModels\ModelsTraningPerformance.mat')

factor=50;

lw=2;
plot(downsample(net1_info.TrainingRMSE,factor),'linewidth',lw)
hold on;
plot(downsample(net3_info.TrainingRMSE,factor),'-.','linewidth',lw)
hold on;
plot(downsample(net4_info.TrainingRMSE,factor),'b:','linewidth',lw)
xlabel("Traning Epochs")
ylabel("Training RMSE")
xlim([0,90])
legend("radar-ecg-net1","radar-ecg-net3","radar-ecg-net4")


figure
plot(downsample(net1_info.TrainingLoss,factor),'linewidth',lw)
hold on;
plot(downsample(net3_info.TrainingLoss,factor),'-.','linewidth',lw)
hold on;
plot(downsample(net4_info.TrainingLoss,factor),'b:','linewidth',lw)
xlim([0,90])
xlabel("Traning Epochs")
ylabel("Training Loss")
legend("radar-ecg-net1","radar-ecg-net3","radar-ecg-net4")