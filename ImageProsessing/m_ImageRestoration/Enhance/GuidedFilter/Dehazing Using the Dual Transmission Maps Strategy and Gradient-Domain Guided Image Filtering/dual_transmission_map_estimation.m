function [t1, t2] = dual_transmission_map_estimation(img_color, AL, w_small, w_large, omega)
% This function will estimate the dual transmission maps: one associated
% with the smaller window size and second with the larger window size
%
% Inputs:   This function will receive five inputs
%   Input1 is img_color, which is a color image of dimension MxNxC
%   Input2 is AL, atmospheric light of size 1xC
%   Input 3 is w_small, a scalar quantity representing smaller winodw size
%   Input 4 is w_large,  a scalar quantity representing the larger window size
%   Input 5 is omega, a scalar, used to control the contribution of each
%   channel
%
% Output: The function will return two outputs:
%
% Output 1 is t1 that is the tranmssion map calculated using the smaller
% window size
% Output 2 is t2, that is the transmission map calculated using the larger
% window size

%% As a first step, we will sort the 0.1% of the brightest pixels of 
% dark channel; that is, img_dark.

[rows, cols, channels] = size(img_color);
rep_atmosphere = repmat(reshape(AL, [1, 1, channels]), rows, cols);

% transmission map using smaller window size
t1 = 1 - omega * dark_channel_computation(img_color./ rep_atmosphere, w_small);

% transmission map using smaller window size
t2 = 1 - omega * dark_channel_computation(img_color./ rep_atmosphere, w_large);
return


