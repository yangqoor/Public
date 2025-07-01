close all; 
clear; 
clc;

xs = im2double(imread('images/barbara_face.png'));


% Motion blur with Poisson noise 
h = im2double(imread('./kernels/eccv3_blurred_kernel.png'));
h = h./sum(h(:));
N = size(xs,1); M = size(xs,2); C = size(xs,3); Hf = psf2otf(h, [N M C]);
f = @(x) real(ifft2(fft2(x(:,:,:)).*Hf));

peak = 1e4;
F = @(x) poissrnd(f(x)*peak)/peak;

y = F(xs);


% Wiener
if (size(y,3) ~= 1)
    ybw = rgb2gray(y);
    NSR = estimate_noise(ybw)^2 / var(ybw(:));
else
    NSR = estimate_noise(y)^2 / var(y(:));
end
g = @(x) deconvwnr(x,h,NSR);
W = g(y); 


% Our schemes 
lm = mLM(F, y); % modified LM
tc = pcVC(F, y); 
iw = mW(F, y);
dfl_opts.maxiter = 500; % follows the paper 
dfL = aL(F, y, dfl_opts); % approximate Landweber 
mRL = mRL(F, y); % modified Richardson-Lucy 


figure();
imshow(y);
title('Blurred image');
fprintf("PSNR of blurred: %f\n", psnr(y, xs));

figure();
imshow(W);
title('Wiener');
fprintf("PSNR of Wiener: %f\n", psnr(W, xs));

figure();
imshow(lm);
title('LM');
fprintf("PSNR of modified LM: %f\n", psnr(lm, xs));

figure();
imshow(iw);
title('Modified Wiener');
fprintf("PSNR of modified Wiener: %f\n", psnr(iw, xs));

figure();
imshow(tc);
title('pcVC');
fprintf("PSNR of phase corrected VC: %f\n", psnr(tc, xs));

figure();
imshow(dfL);
title('Approx. Landweber');
fprintf("PSNR of approximate Landweber: %f\n", psnr(dfL, xs));

figure();
imshow(mRL);
title('Modified RL');
fprintf("PSNR of modified RL: %f\n", psnr(mRL, xs));
