close all; 
clear; 
clc;


xs = im2double(imread('images/barbara_face.png'));


% noisy motion blurry
noise_mean = 0;
noise_var = 0.0001;


h = im2double(rgb2gray(imread('./kernels/testkernel2.bmp')));
h = h./sum(h(:));
N = size(xs,1); M = size(xs,2); C = size(xs,3); Hf = psf2otf(h, [N M C]);
f = @(x) real(ifft2(fft2(x(:,:,:)).*Hf));

F = @(x) imnoise(f(x),'gaussian',noise_mean,noise_var);

y = F(xs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dong 
D = Dong(F, y);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% regular Tao 
% doesn't work for non-symmetric kernels
maxiter = 20;
T = F(y);
for i=1:maxiter
  T = T + (y-F(T));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wiener 
signal_var = var(y(:));
NSR = noise_var / signal_var;
g = @(x) deconvwnr(x,h,NSR);
W = g(y); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% phase corrected VC
Tc = pcVC(F, y);


figure();
imshow(xs); 
title('Original image');

figure();
imshow(y);
title('Blurred image');

figure();
imshow(T);
title('Tao');

figure();
imshow(D);
title('Dong');

figure();
imshow(W);
title('Wiener');

figure();
imshow(Tc);
title('pcVC');
