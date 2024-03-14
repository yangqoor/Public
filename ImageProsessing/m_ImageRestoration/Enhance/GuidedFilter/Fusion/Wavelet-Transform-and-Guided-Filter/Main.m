clear all; close all; clc;

Original_Image_init = imread('mandrill.jpg');

Original_Image = Original_Image_init;

%% Sub image genereation
OverEx_Image = imlocalbrighten(Original_Image_init);
sigma = 0.4;
alpha = 0.6;
UnderEx_Image = locallapfilt(Original_Image_init, sigma, alpha); %stretchlim(Original_Image_init),[]);
OverEx_Image_init = OverEx_Image;
UnderEx_Image_init = UnderEx_Image;

%% RGB 2 HSI
Original_Image = rgb2hsv(Original_Image);
OverEx_Image = rgb2hsv(OverEx_Image);
UnderEx_Image = rgb2hsv(UnderEx_Image);

I_Original = adapthisteq(Original_Image(:, :, 3));
I_OverEx = OverEx_Image(:, :, 3);
I_UnderEx = UnderEx_Image(:, :, 3);

% subplot(2,3,1),imshow(I_Original),title('CLAHE');hold  on
% subplot(2,3,2),imshow(I_OverEx),title('Gamma correction');hold on
% subplot(2,3,3),imshow(I_UnderEx),title('Imadjust');

%% Wavelet decomposition

n = 1; %Enter the decomposition level
dwtmode('per'); %image extension mode

[C_Original, S_Original] = wavedec2(I_Original, n, 'haar');
[cHn_Original, cVn_Original, cDn_Original] = detcoef2('all', C_Original, S_Original, n);
cAn_Original = appcoef2(C_Original, S_Original, 'haar', n); % Extract approximation coefficients

[C_OverEx, S_OverEx] = wavedec2(I_OverEx, n, 'haar');
[cHn_OverEx, cVn_OverEx, cDn_OverEx] = detcoef2('all', C_OverEx, S_OverEx, n);
cAn_OverEx = appcoef2(C_OverEx, S_OverEx, 'haar', n); % Extract approximation coefficients

[C_UnderEx, S_UnderEx] = wavedec2(I_UnderEx, n, 'haar');
[cHn_UnderEx, cVn_UnderEx, cDn_UnderEx] = detcoef2('all', C_UnderEx, S_UnderEx, n);
cAn_UnderEx = appcoef2(C_UnderEx, S_UnderEx, 'haar', n); % Extract approximation coefficients

% -------- Apply guided filter

cHn_Original = imguidedfilter(I_Original, imresize(cHn_Original, size(I_Original)), NeighborhoodSize = [3 3]);
cDn_Original = imguidedfilter(I_Original, imresize(cDn_Original, size(I_Original)), NeighborhoodSize = [3 3]);
cVn_Original = imguidedfilter(I_Original, imresize(cVn_Original, size(I_Original)), NeighborhoodSize = [3 3]);

cHn_UnderEx = imguidedfilter(I_UnderEx, imresize(cHn_UnderEx, size(I_UnderEx)), NeighborhoodSize = [3 3]);
cDn_UnderEx = imguidedfilter(I_UnderEx, imresize(cDn_UnderEx, size(I_UnderEx)), NeighborhoodSize = [3 3]);
cVn_UnderEx = imguidedfilter(I_UnderEx, imresize(cVn_UnderEx, size(I_UnderEx)), NeighborhoodSize = [3 3]);

cHn_OverEx = imguidedfilter(I_OverEx, imresize(cHn_OverEx, size(I_OverEx)), NeighborhoodSize = [3 3]);
cDn_OverEx = imguidedfilter(I_OverEx, imresize(cDn_OverEx, size(I_OverEx)), NeighborhoodSize = [3 3]);
cVn_OverEx = imguidedfilter(I_OverEx, imresize(cVn_OverEx, size(I_OverEx)), NeighborhoodSize = [3 3]);

% imshow(cHn_Original)
%% Fusion rule for the detail coeffs

% ===============Fusion using weights of the coefficients based on local
% contrast and local entropy in 3x3 nhood
% -------------------------Compute the local contrast & local energy of cHn

std_Original_H = stdfilt(cHn_Original);
std_OverEx_H = stdfilt(cHn_OverEx);
std_UnderEx_H = stdfilt(cHn_UnderEx);

entropy_Original_H = entropyfilt(cHn_Original, true(3));
entropy_OverEx_H = entropyfilt(cHn_OverEx, true(3));
entropy_UnderEx_H = entropyfilt(cHn_UnderEx, true(3));

% compute weights

meanStd_Original_H = mean(std_Original_H(:));
meanStd_OverEx_H = mean(std_OverEx_H(:));
meanStd2_UnderEx_H = mean(std_UnderEx_H(:));

meanEntropy_Original_H = mean(entropy_Original_H(:));
meanEntropy_OverEx_H = mean(entropy_OverEx_H(:));
meanEntropy_UnderEx_H = mean(entropy_UnderEx_H(:));

% Define the weight for each image
weight_Original_H = meanStd_Original_H + 2 * (meanEntropy_Original_H);
weight_OverEx_H = meanStd_OverEx_H + 2 * (meanEntropy_OverEx_H);
weight_UnderEx_H = meanStd2_UnderEx_H + 2 * (meanEntropy_UnderEx_H);

%------------------------- Compute the local contrast & local energy of cVn
std_Original_V = stdfilt(cVn_Original);
std_OverEx_V = stdfilt(cVn_OverEx);
std_UnderEx_V = stdfilt(cVn_UnderEx);

entropy_OverEx_V = entropyfilt(cVn_OverEx, true(3));
entropy_UnderEx_V = entropyfilt(cVn_UnderEx, true(3));
entropy_Original_V = entropyfilt(cVn_Original, true(3));

% compute weights

meanStd_Original_V = mean(std_Original_V(:));
meanStd_OverEx_V = mean(std_OverEx_V(:));
meanStd2_UnderEx_V = mean(std_UnderEx_V(:));

meanEntropy_Original_V = mean(entropy_Original_V(:));
meanEntropy_OverEx_V = mean(entropy_OverEx_V(:));
meanEntropy_UnderEx_V = mean(entropy_UnderEx_V(:));

% Define the weight for each image
weight_Original_V = meanStd_Original_V + 2 * (meanEntropy_Original_V);
weight_OverEx_V = meanStd_OverEx_V + 2 * (meanEntropy_OverEx_V);
weight_UnderEx_V = meanStd2_UnderEx_V + 2 * (meanEntropy_UnderEx_V);
%------------------------- Compute the local contrast & local energy
std_Original_D = stdfilt(cDn_Original);
std_OverEx_D = stdfilt(cDn_OverEx);
std_UnderEx_D = stdfilt(cDn_UnderEx);

entropy_OverEx_D = entropyfilt(cDn_OverEx, true(3));
entropy_UnderEx_D = entropyfilt(cDn_UnderEx, true(3));
entropy_Original_D = entropyfilt(cDn_Original, true(3));

% compute weights
meanStd_Original_D = mean(std_Original_D(:));
meanStd_OverEx_D = mean(std_OverEx_D(:));
meanStd2_UnderEx_D = mean(std_UnderEx_D(:));

meanEntropy_Original_D = mean(entropy_Original_D(:));
meanEntropy_OverEx_D = mean(entropy_OverEx_D(:));
meanEntropy_UnderEx_D = mean(entropy_UnderEx_D(:));

% Define the weight for each image
weight_Original_D = meanStd_Original_D + 2 * (meanEntropy_Original_D);
weight_OverEx_D = meanStd_OverEx_D + 2 * (meanEntropy_OverEx_D);
weight_UnderEx_D = meanStd2_UnderEx_D + 2 * (meanEntropy_UnderEx_D);

F_110 = weight_Original_H .* cHn_Original + weight_OverEx_H .* cHn_OverEx + weight_UnderEx_H .* cHn_UnderEx;
F_210 = weight_Original_V .* cVn_Original + weight_OverEx_V .* cVn_OverEx + weight_UnderEx_V .* cVn_UnderEx;
F_310 = weight_Original_D .* cDn_Original + weight_OverEx_D .* cDn_OverEx + weight_UnderEx_D .* cDn_UnderEx;
% imshow(F_210);
%% Fusion rule for the approximation coeffs: Max or energy

wv = 'sym4';
lv = 5;
F_base = wfusimg(cAn_Original, cAn_OverEx, wv, lv, 'mean', 'max');
F_basee = wfusimg(F_base, cAn_UnderEx, wv, lv, 'mean', 'max');

%% Image reconstruction
wv = 'sym4';
S = idwt2(imresize(F_basee, size(F_110)), F_110, F_210, F_310, wv);
Original_Image(:, :, 3) = imresize(S, size(Original_Image(:, :, 3)));

% Original_Image(:,:,2) = Original_Image(:, :, 2)* 1.2;
Original_Image(:, :, 2) = adapthisteq(Original_Image(:, :, 2), 'NumTiles', [8 8], 'ClipLimit', 0.003);

FusedImage = hsv2rgb(Original_Image);

% See the results
%     subplot(2,3,1),imshow(Original_Image_init),title('Input');hold  on
%     subplot(2,3,2),imshow(OverEx_Image_init),title('OverEx Image');hold
%     on subplot(2,3,3),imshow(UnderEx_Image_init),title('UnderEx
%     Image');hold  on
%     subplot(2,3,5),
imshow(FusedImage), title('Output');
%     hold off
%     histogram(FusedImage)
%     imshowpair(Original_Image_init,FusedImage,'montage');

% Metrics
% metric1=entropy(FusedImage);
% C_input=Contrast_II(Original_Image_init);
% C_output=Contrast_II(uint8(FusedImage));
% metric2=C_output/C_input;
% metric3=piqe(FusedImage);
% window = ones(8);
% L = 100;
% [metric4, pcqi_map]= PCQI(im2gray(FusedImage),im2gray(im2double(Original_Image_init)), window, L);
% metric5=psnr(FusedImage,im2double(Original_Image_init));
% metric6 = ssim(FusedImage,im2double(Original_Image_init));
%
% A = {'method','Input','Entropy','CII','PIQE','PCQI','PSNR','SSIM';'Proposed',3179,metric1,metric2,metric3,metric4,metric5,metric6};
% writecell(A,'TestresultsUpdatedmethodNov22.xlsx','WriteMode','append','Sheet','Proposed')
%
%
