% Sample code of the papers:
% 
% Sayantan Dutta, Adrian Basarab, Bertrand Georgeot, and Denis Kouamé,
% "Plug-and-Play Quantum Adaptive Denoiser for Deconvolving Poisson Noisy Images,"
% arXiv preprint arXiv:2107.00407 (2021).
%
% Sayantan Dutta, Adrian Basarab, Bertrand Georgeot, and Denis Kouamé,
% "Poisson image deconvolution by a plug-and-play quantum denoising scheme,"
% in 2021 29th European Signal Processing Conference (EUSIPCO), 2021.
%
% Sayantan Dutta, Adrian Basarab, Bertrand Georgeot, and Denis Kouamé,
% "Quantum mechanics-based signal and image representation: Application
% to denoising," IEEE Open Journal of Signal Processing, vol. 2, pp. 190–206, 2021.
% 
% One should cite all these papers for using the code.
%---------------------------------------------------------------------------------------------------
% MATLAB code prepard by Sayantan Dutta
% E-mail: sayantan.dutta@irit.fr and sayantan.dutta110@gmail.com
% 
% This script shows an example of our image deconvolution algorithm 
% using Quantum adaptative basis (QAB) as a plug-and-play denoiser
% in the ADMM framework
%---------------------------------------------------------------------------------------------------

clear all
close all
clc

% add path ot all related functions
addpath(genpath('./utilities/'));
addpath(genpath('./data/'));

% add path to quantum-adaptive-denoiser
addpath(genpath('./denoiser/QAB_denoiser/'));

% load input data
load Sinthetics_Image.mat

[m,n] = size(I);    % size of the input image
I = I/max(I(:));    % normalize the input image
originalPic = I;    % store clean image


% Generate noisy and blurry image

% initialize a blurring filter
 kernel = fspecial('gaussian',4,3);     % blurring kernel
 
% generator noise
SNR = 20;       % noise level
B = randn(size(I)).* sqrt(abs(I));  % generate random Poisson noise
pI = sum(sum(I .^2)) / (m * n);
pB_tmp = sum(sum(B .^2)) / (m * n);
B = B / sqrt(pB_tmp) * sqrt(pI * 10^(- SNR / 10));  % adjust the noise level

 
% Creat the observed noisy blurred image
y = imfilter(I,kernel,'circular') + B;      % observed image

% display distorted observed image
PSNR_input = psnr(I,y);
fprintf('\nPSNR_in = %3.2f dB \n', PSNR_input);


% Set parameters
gama        = 1.01;     % update penalty parameter by a factor
lambda      = 1.3;      % initial choice of the penalty parameter
energy      = 4.1;      % wave functions below this energy level should consider for restoration
h_cut       = 4;        % value of palnck's constant
sigma       = 7;        % Gaussian Variance (smoothing)


% QAB-PnP-ADMM deblurring
[x, deblurred, history ,ext, conv] = QAB_PnP_deblur(I,y,lambda,gama,kernel,h_cut,sigma,energy);


% Display results
% Calculate output PSNR and SSIM
PSNR_output = psnr(I,deblurred);
SSIM = ssim_index(deblurred, I, [0.01 0.03], fspecial('gaussian', 3, 1.5), max(I(:)));
fprintf('\n Output PSNR = %2.2f dB \n\n Output SSIM_out = %1.3f \n', PSNR_output, SSIM);

% Show computation time
total_time = ext.computation_time;
fprintf('\n Computation time = %.3f seconds\n', total_time);

% Show results
its = 1:ext.MAX_ITER;

figure('Position',[100 100 1300 400])
% Plot PSNR VS iteration graph
subplot(131);
res1 = plot(its,history.PSNR,'r');
set(res1, 'linewidth', 2);
ylabel('PSNR (dB)'); xlabel('Iteration (k)'); title('PSNR vs Iteration');
legend(sprintf('Lambda=%1.3f',lambda),'Location','southeast');

% Plot log(RMSE) VS iteration graph
subplot(132);
res2 = plot(its,log(history.rmse),'r');
set(res2, 'linewidth', 2);
ylabel('log(RMSE)'); xlabel('Iteration (k)'); title('log(RMSE) vs Iteration');
legend(sprintf('Lambda=%1.3f',lambda),'Location','northeast');

% Plot SSIM VS iteration graph
subplot(133);
res3 = plot(its,history.ssim,'r');
set(res3, 'linewidth', 2);
ylabel('SSIM'); xlabel('Iteration (k)'); title('SSIM vs Iteration');
legend(sprintf('Lambda=%1.3f',lambda),'Location','southeast');


% plot output results
figure('Position',[100 100 1300 400])
subplot(131),imagesc(I),colormap('gray'),title('Clean Image')
subplot(132),imagesc(y),colormap('gray'),title(sprintf('Observed image: PSNR=%2.2f',PSNR_input))
subplot(133),imagesc(deblurred),colormap('gray'),title(sprintf('Proposed deblurred image: PSNR=%2.2f',PSNR_output))
