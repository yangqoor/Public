function AL = atmospheric_light_estimation(img_color, img_dark)
% This function will estimate the atmospheric light parameters
% for any color image of dimensions MxNxC using the dark channel
% of size MxN
% Inputs:   This function will receive two inputs
%   Input1 is img_color, which is a color image of dimension MxNxC
%   Input2 is img_dark, the dark channel of img_color, and its dimension
%   is MxN
%
% Output: The function will return an array of three numbers, each number
% represents the airlight estimation of each color of the input color
% image.

%% As a first step, we will sort the 0.1% of the brightest pixels of 
% dark channel; that is, img_dark.

[rows, cols, channels] = size(img_color);
num_of_pixels = rows * cols;
num_of_pixels_req = floor(num_of_pixels*0.1/100);

% converting dark channel and original color image to arrays
img_dark_array = reshape(img_dark, num_of_pixels, 1);
img_color_array = reshape(img_color, num_of_pixels, 3);

% Sorting the pixels of dark channel array
[~, pix_indices] = sort(img_dark_array);
%Extracting the indices of only 0.1% bright pixels
req_indices = pix_indices(num_of_pixels - num_of_pixels_req+1:end);


%% Computing the Atmospheric Lights for each channel
AL = zeros(1, channels);
for x = 1:num_of_pixels_req
    AL = AL + img_color_array(req_indices(x),:);
end

AL = AL/num_of_pixels_req;

return


