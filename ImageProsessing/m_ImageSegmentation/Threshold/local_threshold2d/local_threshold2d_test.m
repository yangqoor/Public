%% clear
clc; clear all; close all;

%% path
% addpath('./lib')
addpath('.\lib')
%% load image
im = imread('.\im\text.png');

%% local thresholding
n = 45; 

c = 0;
imth1 = mean_threshold2d(im,n,c);

c = 0;
imth2 = median_threshold2d(im,n,c);

c = 0;
imth3 = mid_grey_threshold2d(im,n,c);

k = 0.01;
imth4 = niblack_threshold2d(im,n,k);

c = n;
imth5 = bernsen_threshold2d(im,n,c);

k = 0.5; R = 128;
imth6 = sauvola_threshold2d(im,n,k,R);

%% plot
figure,
imagesc(im); title('Input'); colormap gray; 
set(gca,'ytick',[]); set(gca,'xtick',[]); axis image; axis tight;

figure,
subplot(2,3,1), imagesc(imth1); title('Mean'); colormap gray; 
set(gca,'ytick',[]); set(gca,'xtick',[]); axis image; axis tight;

subplot(2,3,2), imagesc(imth2); title('Median'); colormap gray; 
set(gca,'ytick',[]); set(gca,'xtick',[]); axis image; axis tight;

subplot(2,3,3), imagesc(imth3); title('MidGrey'); colormap gray; 
set(gca,'ytick',[]); set(gca,'xtick',[]); axis image; axis tight;

subplot(2,3,4), imagesc(imth4); title('Niblack'); colormap gray; 
set(gca,'ytick',[]); set(gca,'xtick',[]); axis image; axis tight;

subplot(2,3,5), imagesc(imth5); title('Bernsen'); colormap gray; 
set(gca,'ytick',[]); set(gca,'xtick',[]); axis image; axis tight;

subplot(2,3,6), imagesc(imth6); title('Sauvola'); colormap gray; 
set(gca,'ytick',[]); set(gca,'xtick',[]); axis image; axis tight;