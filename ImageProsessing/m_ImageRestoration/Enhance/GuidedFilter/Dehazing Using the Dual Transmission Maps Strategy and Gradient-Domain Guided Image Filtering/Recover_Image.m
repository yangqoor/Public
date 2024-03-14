function restored_img = Recover_Image(img_color,refined_trans_map,Atmospheric_light)
% This function will recover the haze free image using the orignal hazy
% image, refined transmission map, and atmospheric lights

% Inputs:   This function will receive three inputs
%   Input1: img_color is original hazy image of size MxNxC
%   Input2: refined_trans_map is the refined transmission map of size MxN
%   Input 3: Atmoshperic Lights for each channel
%
% Output: The function will return only one output.
%
% Output: restored_image is the recovered haze-free image of size MxNxC

[rows, cols, channels] = size(img_color);
rep_atmosphere = repmat(reshape(Atmospheric_light, [1, 1, channels]), rows, cols);
max_transmission = repmat(max(im2double(refined_trans_map), 0.1), [1, 1, channels]);
restored_img = ((img_color - rep_atmosphere) ./ max_transmission) + rep_atmosphere;
return


