addpath utils/
addpath weights/
addpath images/
addpath Tools/
addpath Tools/boundary/
addpath cuda/

kernel_str = 'disk7';
mode_1 = 'jpeg + noise + saturation';
mode_2 = 'jpeg + saturation';

% specify the mode
mode = mode_1;

orig = imread('images/sample_GT.png');
init_gpu(1);
fprintf('loading weights...\n');
if strcmp(mode, mode_1)    
    imTest = im2double(imread('images/sample_blur_noise.jpg'));
    load(strcat('weights/', kernel_str, '/w_noise'));
else
    imTest = im2double(imread('images/sample_blur.jpg'));
    load(strcat('weights/', kernel_str, '/w_nonoise'));
end


kx = double(config.weights.C1);
ky = double(config.weights.C2);
kx = kx';
ky = ky';
kx = flip(kx, 1);
ky = flip(ky, 1);
kw = double(config.weights.W1);
bc1 = double(config.weights.bc1);
bc2 = double(config.weights.bc2);

featureMapNum = config.deconv_hidden_size(1);

fprintf('padding blur image...\n');
sizeOrig = size(imTest);

if(strcmp(kernel_str, 'disk7'))
    G = fspecial('disk', 7);
    GPad = padarray(G, [61,61]);
end

GPad(:,121) = [];
GPad(121,:) = [];
[imTestYUVPadded, ypadpre, ypadpost,xpadpre, xpadpost] = myPadImgforDeblur1(imTest, GPad);     


output_R = zeros(sizeOrig(1)+16, sizeOrig(2)+16, featureMapNum);
output_G = zeros(sizeOrig(1)+16, sizeOrig(2)+16, featureMapNum);
output_B = zeros(sizeOrig(1)+16, sizeOrig(2)+16, featureMapNum);

tic
fprintf('deblur stage 1...\n');
for m = 1 : featureMapNum
    chs = imTestYUVPadded(:,:,1);
    imgH_a = sigmoid(conv2(chs, kx(:,m)', 'valid') + bc1(m));
    imgV_a = sigmoid(conv2(imgH_a, ky(:,m), 'valid') + bc2(m));
    output_R(:,:,m) = imgV_a;

    chs = imTestYUVPadded(:,:,2);
    imgH_a = sigmoid(conv2(chs, kx(:,m)', 'valid') + bc1(m));
    imgV_a = sigmoid(conv2(imgH_a, ky(:,m), 'valid') + bc2(m));
    output_G(:,:,m) = imgV_a;    

    chs = imTestYUVPadded(:,:,3);
    imgH_a = sigmoid(conv2(chs, kx(:,m)', 'valid') + bc1(m));
    imgV_a = sigmoid(conv2(imgH_a, ky(:,m), 'valid') + bc2(m));
    output_B(:,:,m) = imgV_a;    
end
output = cat(4, output_R, output_G, output_B);


R = sum(bsxfun(@times, output_R, reshape(kw, 1, 1, [])), 3);
G = sum(bsxfun(@times, output_G, reshape(kw, 1, 1, [])), 3);
B = sum(bsxfun(@times, output_B, reshape(kw, 1, 1, [])), 3);
% intermediate result, for comparison
deconv_output = cat(3, R, G, B);
deconv_output = deconv_output(9:size(deconv_output, 1)-8, 9:size(deconv_output, 2)-8, :);

fprintf('deblur stage 2...\n');
prepare_subnet2(size(output, 1), size(output, 2), config);
final_output = apply_subnet2(gpuArray(single(output)));
toc
final_output = gather(final_output);
final_output = uint8(double(final_output)*255);
final_output = final_output(9:size(final_output, 1)-8, 9:size(final_output, 2)-8, :);
figure, imshow([im2double(imTest), deconv_output, double(im2double(final_output))]);
title('LEFT: input blurry image,   MIDDLE: intermediate result,   RIGHT: final result')
drawnow();
imwrite(final_output, 'dcnn.png');

[PSNR, MSE] = psnr(orig, final_output);
fprintf('PSNR: %f\n', PSNR);




