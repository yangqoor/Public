function deconv_test


img = imread('../examples/1_city_night_view_synthetic/blurred.png');
img = double(img)/255;

psf = imread('../examples/1_city_night_view_synthetic/psf.png');
if size(psf,3) == 3
    psf = rgb2gray(psf);
end
psf = double(psf);
psf = psf / sum(psf(:));

% sigma: standard deviation for Gaussian noise (for inlier data)
% reg_str: regularization strength for sparse priors
sigma = 5/255;
reg_str = 0.003;
deblurred = deconv_outlier(img, psf, sigma, reg_str);

figure
imshow(deblurred);

