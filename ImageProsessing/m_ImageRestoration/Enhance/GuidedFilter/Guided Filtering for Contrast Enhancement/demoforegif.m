close all;

I = double(imread('kodim23.png')) / 255;
p = I;
r = 16;
eps = 0.01;

q = zeros(size(I));
I_enhanced = zeros(size(I));

[q(:, :, 1), beta] = egif(I(:, :, 1), p(:, :, 1), r, eps);
I_enhanced(:, :, 1) = (I(:, :, 1) - q(:, :, 1)) .* beta + q(:, :, 1);
[q(:, :, 2), beta] = egif(I(:, :, 2), p(:, :, 2), r, eps);
I_enhanced(:, :, 2) = (I(:, :, 2) - q(:, :, 2)) .* beta + q(:, :, 2);
[q(:, :, 3), beta] = egif(I(:, :, 3), p(:, :, 3), r, eps);
I_enhanced(:, :, 3) = (I(:, :, 3) - q(:, :, 3)) .* beta + q(:, :, 3);

figure;
subplot(1, 2, 1); imshow(I); title('input');
subplot(1, 2, 2); imshow(I_enhanced); title('enhanced');
