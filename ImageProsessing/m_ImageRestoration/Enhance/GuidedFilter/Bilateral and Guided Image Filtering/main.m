%% Sandeep Manandhar
%Implementation of Bilateral and Guided Image filters
%Advanced Image analysis
%Universite de Bourgogne
%Masters in Computer Vision
%<manandhar.sandeep@gmail.com>
%% Input Images and parameters
Im = double(imread('mandrill.jpg'))/255;  %color
grayIm = double(rgb2gray(imread('oldpatan.jpg')))/255;  %gray

window = 5;    %kernel size
sigma_s = 2;   %distance std deviation
sigma_r = 0.1; %range std deviation
%% bilateral in gray
disp('Applying grayscale bilateral filtering');
tic;
bilatG = bilateralGray(grayIm, window, sigma_s, sigma_r);
toc
figure(1); subplot(121);imshow(grayIm,[]); title('Original Image');
subplot(122);imshow(bilatG,[]); title('bilateral filtered');
%% biltarel in color
disp('Applying color bilateral filtering');
tic;
bilatC = bilateralColor(Im, window, sigma_s, sigma_r*100);
toc
figure(2); subplot(121);imshow(Im,[]); title('Original Image');
subplot(122);imshow(bilatC,[]); title('bilateral filtered'); colormap gray;
%% Guided Image filtering
disp('Applying Guided Image bilateral filtering');
tic;
guidFil = guidedfilter(grayIm, grayIm, window, sigma_s, sigma_r);
figure(3); subplot(121);imshow(grayIm,[]);title('Original Image');
subplot(122);imshow(guidFil,[]);title('Guided Image Filtered');
toc
