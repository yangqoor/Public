
clear all
close all
clc

%% main

% data folder
path = '..\reference\';
% filename
measurement = '7.3';

% read file
[referenceRaw,referenceFrequency] = readReferenceData(path,measurement);

% time array (raw data)
t1 = (0:numel(referenceRaw)-1)*1/256/60;
% time array (frequency values)
t2 = (0:numel(referenceFrequency)-1)*1/1/60;

%% plot

figure
subplot(2,1,1)
plot(t1,referenceRaw)
xlabel('Time (minutes)')
ylabel('Amplitude')
xlim([0 25])
subplot(2,1,2)
plot(t2,referenceFrequency,'r')
xlabel('Time (minutes)')
ylabel('Frequency (bpm)')
xlim([0 25])
