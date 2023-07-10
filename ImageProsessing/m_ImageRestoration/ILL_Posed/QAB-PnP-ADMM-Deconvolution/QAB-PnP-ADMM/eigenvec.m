% Sample code of the paper:
%
% Sayantan Dutta, Adrian Basarab, Bertrand Georgeot, and Denis Kouam�,
% "Quantum mechanics-based signal and image representation: Application
% to denoising," IEEE Open Journal of Signal Processing, vol. 2, pp. 190�206, 2021.
%
% MATLAB code prepard by Sayantan Dutta
% E-mail: sayantan.dutta@irit.fr and sayantan.dutta110@gmail.com
%
% This script shows an example of calling our denoising algorithm
% for image using Quantum adaptative basis (QAB)
%-----------------------------------------------------------------------------------------------

function [psi, psi_col, E] = eigenvec(I, h_cut, sigma)
    % use Gaussian blurring
    [n, n2] = size(I); % assume n = n2
    nn = n ^ 2;
    pds = h_cut; % value of palnck's constant
    sg = sigma; % Gaussian Variance (smoothing) % Variance of the blur before calculation
    [x, x1] = meshgrid((-n / 2):(n / 2 - 1));
    z = 1 / (sqrt(2 * pi * sg)) ^ 2 * exp(- (x .^ 2 + x1 .^ 2) / (2 * sg));
    % Convolution product
    gaussF = fft2(ifftshift(z));
    yF = fft2(I);
    y_n = real(ifft2(gaussF .* yF));

    % Calculation of the eigenvectors then projection in the base
    [psi, psi_col, E] = f_ondes2D(y_n, pds);

end
