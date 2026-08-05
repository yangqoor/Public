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

load("TraninedModels\TraninedRadarECGnets.mat")
load("Dataset\TestData.mat")

%4D input: Radar Phase, Heartbeat sigal, output singal in level 3 and level 4 using Daubechies Wavelet
test_x=TestData(:,1);
ground_truth=TestData(:,2);


plot_flag=1;

%1D input: Radar Phase Signal
test_x_1=extraction_data(test_x,1,1);

%3D input: Heartbeat sigal, output singal in level 3 and level 4 using Daubechies Wavelet
test_x_3=extraction_data(test_x,2,4);


numCells = numel(test_x_1); %Number of cells in the array
rmse = zeros(numCells, 1);   %Initialize a new cell array to store the results

fs=200;
t=0:1:length(ground_truth{1})-1;
t=t./fs;
lw=1;

for i = 1:numCells
    % Access each cell
    ecg=ground_truth{i};

    Reconstructed_ecg(1,:) = predict(radar_ecg_net_1_input,test_x_1{i});
    Reconstructed_ecg(2,:) = predict(radar_ecg_net_3_input,test_x_3{i});
    Reconstructed_ecg(3,:) = predict(radar_ecg_net_4_input,TestData{i});

    if(plot_flag)
        figure(100)
        subplot(5,1,1);
        plot(t,TestData{i}(1,:),'LineWidth',lw);title("Radar phase signal");
        xlim([0,t(end)]);   ylabel('Amplititude'); xlabel('Time (s)');
        subplot(5,1,2);
        plot(t,Reconstructed_ecg(1,:),'LineWidth',lw);title("radar ecg net1");
        xlim([0,t(end)]);   ylabel('Amplititude'); xlabel('Time (s)');
        subplot(5,1,3);
        plot(t,Reconstructed_ecg(2,:),'LineWidth',lw);title("radar ecg net3");
        xlim([0,t(end)]);  ylabel('Amplititude'); xlabel('Time (s)');
        subplot(5,1,4);
        plot(t,Reconstructed_ecg(3,:),'LineWidth',lw);title("radar ecg net4");
        xlim([0,t(end)]);   ylabel('Amplititude'); xlabel('Time (s)');
        subplot(5,1,5);
        plot(t,ecg,'LineWidth',lw);title(" Ground truth (ECG)"); 
        xlim([0,t(end)]);   ylabel('Amplititude'); xlabel('Time (s)');
        drawnow;
        pause(1)
    end
   
end
