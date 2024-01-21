function [k_centered, varargout] = center_kernel(k, xf)
% Slightly modified from 
% Blind deconvolution using a normalized sparsity measure
% http://cs.nyu.edu/~dilip/research/code/blinddeconv.tgz
%
% Get center of mass
c_x = sum([1:size(k, 2)] .* sum(k, 1));    
c_y = sum([1:size(k, 1)] .* sum(k, 2)');
  
% get mean offset
offset_x = round( floor(size(k, 2) / 2) + 1 - c_x );
offset_y = round( floor(size(k, 1) / 2) + 1 - c_y );

% construct translation kernel
shift_kernel = zeros(abs(offset_y * 2) + 1, abs(offset_x * 2) + 1);
shift_kernel(abs(offset_y) + 1 + offset_y, abs(offset_x) + 1 + offset_x) = 1;

k_centered = k;
if nargin == 2,
    varargout{1} = xf;
end

% shift both image and blur kernel
if offset_x ~=0 || offset_y ~=0,
    k_centered = conv2(k, shift_kernel, 'same');
    
    
    % if also the images are given, translate them as well
    if nargin == 2,
        for j=1:length(xf),
            xf{j} = conv2(xf{j} , shift_kernel, 'same');
        end
        varargout{1} = xf;
    end
    
    
end
    