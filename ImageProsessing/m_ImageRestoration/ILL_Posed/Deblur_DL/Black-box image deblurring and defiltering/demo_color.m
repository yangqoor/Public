close all; 
clear; 
clc;


% Starfish 
xs = im2double(imread('images/starfish.png'));


% noisy motion blurry
noise_mean = 0;
noise_var = 0.00001;

h = im2double(rgb2gray(imread('./kernels/testkernel2.bmp')));
h = h./sum(h(:));
N = size(xs,1); M = size(xs,2); C = size(xs,3); Hf = psf2otf(h, [N M C]);
f = @(x) real(ifft2(fft2(x(:,:,:)).*Hf));

F = @(x) imnoise(f(x),'gaussian',noise_mean,noise_var);

y = F(xs);


lm = mLM(F, y); % modified LM
W = mW(F, y); 
dfl_opts.maxiter = 500; % follows the paper 
dfL = aL(F, y, dfl_opts); % approximate Landweber 


figure();
imshow(xs);
title('Input image'); 

figure();
imshow(y);
title('Blurred image');
fprintf("PSNR of blurred: %f\n", psnr(y, xs));

figure();
imshow(lm);
title('LM');
fprintf("PSNR of modified LM: %f\n", psnr(lm, xs));

figure();
imshow(W);
title('Modified Wiener');
fprintf("PSNR of modified Wiener: %f\n", psnr(W, xs));

figure(); 
imshow(dfL);
title('Approx. Landweber');
fprintf("PSNR of approximate Landweber: %f\n", psnr(dfL, xs));


% Parrot 
%close all; 
clear; 
%clc;


xs = im2double(imread('images/parrots.png'));


% noisy motion blurry
noise_mean = 0;
noise_var = 0.00001;

h = im2double(rgb2gray(imread('./kernels/testkernel2.bmp')));
h = h./sum(h(:));
N = size(xs,1); M = size(xs,2); C = size(xs,3); Hf = psf2otf(h, [N M C]);
f = @(x) real(ifft2(fft2(x(:,:,:)).*Hf));

F = @(x) imnoise(f(x),'gaussian',noise_mean,noise_var);

y = F(xs);


lm = mLM(F, y); % modified LM
W = mW(F, y);
dfl_opts.maxiter = 500; % follows the paper 
dfL = aL(F, y, dfl_opts); % approximate Landweber 


figure();
imshow(xs);
title('Input image');

figure();
imshow(y);
title('Blurred image');
fprintf("PSNR of blurred: %f\n", psnr(y, xs));

figure();
imshow(lm);
title('LM');
fprintf("PSNR of modified LM: %f\n", psnr(lm, xs));

figure();
imshow(W);
title('Modified Wiener');
fprintf("PSNR of modified Wiener: %f\n", psnr(W, xs));

figure();
imshow(dfL);
title('Approx. Landweber');
fprintf("PSNR of approximate Landweber: %f\n", psnr(dfL, xs));
