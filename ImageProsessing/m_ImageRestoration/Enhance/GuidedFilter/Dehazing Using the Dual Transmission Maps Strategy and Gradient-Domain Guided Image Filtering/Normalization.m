function [J_gray, J_color] = Normalization(I)
%% This function will convert any color image of size MxNxC
% into gray scaleimage after normalizing it
%
% Inputs: I --> a color image
% Outputs: This function will return two images:
%         J_color --> a normalized color image
%         J_gray --> a normalized grayscale version

J_color = double(I)/255;
J_gray = rgb2gray(J_color);
return 