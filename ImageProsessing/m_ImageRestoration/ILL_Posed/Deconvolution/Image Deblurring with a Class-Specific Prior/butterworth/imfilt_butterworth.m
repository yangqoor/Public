% Filter an image with a Butterworth filter created by Peter Kovesi.
% Input:
%   I: input image.
%   f: Butterworth filter.
%
% Output:
%   J: output image.
%   
function [J] = imfilt_butterworth(I, f)   
    
    % Shift the quadrants to be consistent with the Fourier transform of the kernel f
    F_I = fft2(I); 
    
    % The convolution theorem says we just use pointwise multiplication.
    % Remember to perform ifftshift to swap the quadrants back
    J = ifft2( F_I .* f );
end