%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        ssourceTB.m
% Dependencies:    -
% 
% MATLAB v:        8.0.0 (R2012b)
% 
% Organization:    SAL
% Design by:       
% Feedback:                 
%                  ___
%
% License:         MIT
% 
% 
%  ADDITIONAL NOTES:
%  _________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

%Predefined variables
fs = 48000;
shortBufSize = 100;
normalBufSize = 2000;
longBufSize = 10000;

%% Kronecker function
ssKronecker = ssource(shortBufSize, fs);

ssKronecker.kronecker();
%Figure 1
ssKronecker.plotData();

%% Trigonometric
ssTrigonometric = ssource(normalBufSize, fs);

ssTrigonometric.trigonometric(1, 100);
%Figure 2
ssTrigonometric.plotData();

ssTrigonometric.trigonometric([0,1,0,1,0], 1000);
%Figure 3
ssTrigonometric.plotData();

F(2000) = 0;
p = 100;
for (t = 1:2000) F(t) = p; p = p + 0.5; end;
ssTrigonometric.trigonometric(1, F);
%Figure 4
ssTrigonometric.plotData();

DC(2000) = 0;
p = 0;
for (t = 1:2000) DC(t) = p; p = p + 0.005; end;
ssTrigonometric.trigonometric(1, 1000, pi/2, DC);
%Figure 5
ssTrigonometric.plotData();

%% Square 
ssSquare = ssource(normalBufSize, fs);

ssSquare.square(1, 100, 0.5);
%Figure 6
ssSquare.plotData();

ssSquare.square(1, 100, [0.1,0.5]);
%Figure 7
ssSquare.plotData();

%% Tooth
ssTooth = ssource(normalBufSize, fs);

ssTooth.symmetricalTooth(1, 100);
%Figure 8
ssTooth.plotData();

%% Noise
ssNoise = ssource(longBufSize, fs);

ssNoise.noise([4,0.5,5], 1000);
%Figure 9
ssNoise.plotData();



