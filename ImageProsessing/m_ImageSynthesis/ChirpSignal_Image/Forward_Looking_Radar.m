%% Question 1
close all;
clear all;
clc
%%
%{
            Kianoush Aqabakee
          student ID: 9512103311
%}
%%
img = imread('ships.jpg');
%img=imread('u2.jpg');
img = rgb2gray(img);
%% Chirp signal generation
omega = linspace(-pi, pi, 1024);
t = 0:500000; % *100
a = zeros(1, 4001);
T = t(1:100000); % *100
signal = exp(j * (0.1 * T + 0.0006 * T .* T));
chirp = cat(2, signal, a);
%% Deramping
img2 = zeros(size(img));

for i = 1:size(img, 1)
    img2(i, :) = Deramping(double(img(i, :)), chirp);
end

img2 = img2 / max(max(img2));
%% Plot
figure
imshow(img)
title('main image')
figure
img2 = cast(img2 * 256, 'uint8');
imshow(img2)
title('radar image')
