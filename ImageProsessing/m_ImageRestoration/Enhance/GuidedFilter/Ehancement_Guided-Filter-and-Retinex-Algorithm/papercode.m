newImageRGB = imread('.\img\1_banana_noise.jpg');
figure(1);
imshow(newImageRGB);

% %--------------Histogram Equalization-----------------
bin=255;
Val=reshape(newImageRGB,[],1);
Val=double(Val);
I=hist(Val,0:bin);
Output=I/numel(newImageRGB);
CSum=cumsum(Output);
HIm=CSum(newImageRGB+1);
HIm=uint8(HIm*bin);
%figure, imshow(HIm);

grayimg = im2gray(HIm);
grayimg = im2double(grayimg);

%  AInv = imcomplement(newImageRGB);
% %BInv = imreducehaze(AInv);
% BInv = imreducehaze(AInv, 'Method','approx','ContrastEnhancement','boost');
% %[BInv, TInv] = imreducehaze(AInv, 'Method', 'approxdcp', 'ContrastEnhancement', 'none');
% B = imcomplement(BInv);
% figure(1000);
% imshow(HIm);
% % %B = imguidedfilter(B);

newImageHSV = rgb2hsv(HIm);
H = newImageHSV(:,:,1);
S = newImageHSV(:,:,2);
V = newImageHSV(:,:,3);
 figure(2);
 imshow(V);

%--------------------------guided_work--------------------------------

% original = grayimg;    %reference(guidance) image for guided filter 
% p = V;             %guided image 
% r = 4;
% eps = 0.009^2; % try eps=0.1^2, 0.2^2, 0.4^2
% q = guidedfilter(original, p, r, eps);
guide=grayimg;
input=V;
win_size = 5;

q = guidedfilter(input, guide, 1, win_size);
figure(3);
 imshow(q);

% V=filtered;
%      newImage = cat(3, H, S, V);
%      final = hsv2rgb(newImage);
%      
%      figure(3);
%      imshow(final);

%-------------------------retinex call --------------------------------
afterretinex = retinex_frankle_mccann(q,5);

%-------------------------revert back to original image-----------------
V = afterretinex;
hsvimg = cat(3, H, S, V);
afterhsv = hsv2rgb(hsvimg);
afterhsv = afterhsv * 255;
finalRGB = uint8(afterhsv);

figure(4);
imshow(finalRGB);
figure(5);
imshowpair(newImageRGB,finalRGB,'montage');


%-------------------------INPUT calculate mean, std. dev, entropy--------------
imgmean = mean2(newImageRGB);
imgstddev = std2(newImageRGB);
imgentropy = entropy(newImageRGB);

fprintf('Mean : ');
disp(imgmean);
fprintf('Std. deviation: ');
disp(imgstddev)
fprintf('Entropy: ');
disp(imgentropy);

%-------------------------OUTPUT calculate mean, std. dev, entropy--------------
imgmean = mean2(finalRGB);
imgstddev = std2(finalRGB);
imgentropy = entropy(finalRGB);

fprintf('Mean : ');
disp(imgmean);
fprintf('Std. deviation: ');
disp(imgstddev)
fprintf('Entropy: ');
disp(imgentropy);


% [peaksnr, snr] = psnr(finalRGB, newImageRGB);
% fprintf('Peak-SNR: %0.4f\n', peaksnr);
% fprintf('SNR: %0.4f\n', snr);