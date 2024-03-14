function J = dark_channel_computation(img_color, w1)
% This function will compute the dark channel of an input color image.
%
%  Inputs: This function will receive two inputs: Input1: img_color: --> a
%  color image of size MxNxC Input2: w1 --> the size of the filter or
%  window size
%
% Outputs: This function will return only one output and that is the dark
% channel of the input color image. Output: J --> a dark channel of size
% MxN


% estimating the number of rows and columns of original image
[rows, cols, ~] = size(img_color);


% computing the number of rows and columns required for padding
pad_size = floor(w1/2);
padded_img =  padarray(img_color, [pad_size pad_size], Inf);

J = zeros(rows, cols);
for j = 1 : rows
    for i = 1 : cols
  
        patch = padded_img(j : j + (w1-1), i : i + (w1-1), :);
        J(j,i) = min(patch(:));
     end
end



return