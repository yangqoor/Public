
clear all
close all
clc
  
%% main

% data folder
path = '..\radar';
% filename
measurement = '10.3';

% read file
[bI_st,bQ_st] = readRadarRaw(path,measurement);

% time array
t = (0:numel(bI_st)-1)*1/16/60;

%% plot

figure
plot(t,bI_st)
hold on
plot(t,bQ_st)
xlabel('Time (minutes)')
ylabel('Amplitude')
legend('I','Q')
