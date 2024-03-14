clear all;
clc;
addpath('./operations')

im_input=imread('./images/input_7.png');

if size(im_input, 3) == 3
    im_input = rgb2gray(im_input);
end
% figure,imshow(im_input);
im_input=double(im_input)/255;

tic;
[row, column]=size(im_input);
% 1D row guided filtering
for i=1:row
    smooth(i,:)=rowguidedfilter(im_input(i,:),im_input(i,:),4,0.4^2);
end
% In our implementation we set r=4 for a 384*288 resolution image. r=4 means
% w=9=2*r+1;
highpart = im_input - smooth;

% 1D column guided filtering
for j=1:column
    strip(:,j)=columnguidedfilter(smooth(:,j),highpart(:,j),round(0.5*(row*0.25-1)),0.2^2);
end

texture = highpart-strip;
im_output = im_input-strip;
toc;

figure,imshow(im_output);
