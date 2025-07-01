close all; 
clear; 
clc;


xs = im2double(imread('images/barbara_face.png'));


% noisy motion blurry
noise_mean = 0;
noise_var = 0.00001;

h = im2double(imread('./kernels/eccv3_blurred_kernel.png'));
h = h./sum(h(:));
N = size(xs,1); M = size(xs,2); C = size(xs,3); Hf = psf2otf(h, [N M C]);
f = @(x) real(ifft2(fft2(x(:,:,:)).*Hf));

F = @(x) imnoise(f(x),'gaussian',noise_mean,noise_var);

y = F(xs);


% Wiener 
signal_var = var(y(:));
NSR = noise_var / signal_var;
g = @(x) deconvwnr(x,h,NSR);
W = g(y); 


lm = mLM(F, y); % modified LM
T = pcVC(F, y); % corrected VC 
iW = mW(F, y);
dfl_opts.maxiter = 500; % follows the paper 
dfL = aL(F, y, dfl_opts); % approximate Landweber 
mrl = mRL(F, y); % modified Richardson-Lucy 


% Results
figure();
imshow(y);
title('Blurred image');
fprintf("PSNR of blurred: %f\n", psnr(y, xs));

figure();
imshow(W);
title('Classical Wiener');
fprintf("PSNR of Wiener: %f\n", psnr(W, xs));

figure();
imshow(lm);
title('LM');
fprintf("PSNR of modified LM: %f\n", psnr(lm, xs));

figure();
imshow(iW);
title('Modified Wiener');
fprintf("PSNR of modified Wiener: %f\n", psnr(iW, xs));

figure();
imshow(T);
title('pcVC');
fprintf("PSNR of phase corrected VC: %f\n", psnr(T, xs));

figure(); 
imshow(dfL);
title('Approx. Landweber');
fprintf("PSNR of approximate Landweber: %f\n", psnr(dfL, xs));

figure();
imshow(mrl);
title('Modified RL');
fprintf("PSNR of modified RL: %f\n", psnr(mrl, xs));
