close all;
clear;
clc;


disp('Gaussian blur with Gaussian noise');


xs = im2double(imread('images/barbara_face.png'));


% noisy motion blurry
noise_mean = 0;
noise_var = 0.00001;

% default padding is 'replicate'
f = @(x) imgaussfilt(x, 3, 'Padding', 'circular');
F = @(x) imnoise(f(x),'gaussian',noise_mean,noise_var);

y = F(xs);


% Sample the kernel for Wiener and deconv-tv
d = zeros(11, 11);
d(6,6) = 1.0;
h = f(d); 
h = h./sum(h(:)); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wiener
signal_var = var(y(:));
NSR = noise_var / signal_var;
g = @(x) deconvwnr(x,h,NSR);
W = g(y); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Regular Tao
opts.maxiter = 20;
[T, ~] = Tao_orig(F, y, opts);
%T = T(ps+1:end-ps,ps+1:end-ps,:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Phase corrected 
[Tc, ~] = pcVC(F, y);
%Tc = Tc(ps+1:end-ps,ps+1:end-ps,:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modified Wiener
[iW, ~] = mW(F, y);
%iW = iW(ps+1:end-ps,ps+1:end-ps,:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LM
[lm, ~] = mLM(F, y);
%lm = lm(ps+1:end-ps,ps+1:end-ps,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dfl_opts.maxiter = 500; % follows the paper 
[dfL, ~] = aL(F, y, dfl_opts); % approximate Landweber 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[mrl, ~] = mRL(F, y); % modified Richardson-Lucy 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print psnr 
% Note: the padding seems to affect the psnr
fprintf("PSNR of Wiener: %f\n", psnr(W, xs));
fprintf("PSNR of (original) Tao: %f\n", psnr(T, xs));
fprintf("PSNR of phase-corrected VC: %f\n", psnr(Tc, xs));
fprintf("PSNR of modified Wiener: %f\n", psnr(iW, xs));
fprintf("PSNR of modified LM: %f\n", psnr(lm, xs));
fprintf("PSNR of approximate Landweber: %f\n", psnr(dfL, xs)); 
fprintf("PSNR of modified Richardson-Lucy: %f\n", psnr(mrl, xs));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show all images
%
figure();
imshow(y);
title('Blurred image');

figure();
imshow(W);
title('Classic Wiener');

figure();
imshow(T);
title('Tao');

figure();
imshow(Tc);
title('pcVC');

figure();
imshow(iW);
title('Modified Wiener');

figure();
imshow(lm);
title('LM');

figure();
imshow(dfL);
title('Approx. Landweber');

figure();
imshow(mrl);
title('Modified RL');
