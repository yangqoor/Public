% This code is the implementation of Frank Wolfe algorithm in paper
% "Normalized Blind Deconvolution" ECCV 2018

clear
addpath('lib/');
addpath('FW/');
%% -----------------------------------------------------------------------%
%                                  Input                                  %
% ------------------------------------------------------------------------%
g = imread('levin_input.png');
%% -----------------------------------------------------------------------%
%                                Parameters                               %
% ------------------------------------------------------------------------%
% kernel size
MK = 31;
NK = 31;
% regularization parameter. It is not tuned.
lambda = 0.008;
% Lp norm
params.P = 2; 
params.gammaCorrection = false;
params.gamma = 0;
% number of iterations in each pyramid level
params.iters = 30;
params.x_iter = 50;
params.k_iter = 50;
% visualization
params.visualize = 1;
% increase kernel size at each pyramid level, the larger, the fewer level
params.kernelSizeMultiplier = 1.2;

%% -----------------------------------------------------------------------%
%                                  Deblur                                 %
% ------------------------------------------------------------------------%
tic
[u, k] = deblur(g,MK,NK,lambda, params);
toc
u(u<0) = 0;
u(u>1) = 1;
imwrite(u,'out.png');
imwrite(imresize(k./max(k(:)),5,'nearest'),'kernel.png');

