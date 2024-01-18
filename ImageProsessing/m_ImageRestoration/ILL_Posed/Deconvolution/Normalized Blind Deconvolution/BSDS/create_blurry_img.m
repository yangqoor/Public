clear
clc
% adding gaussian noise
noise_level = 0.01;
folder = './Berkeley_noise1/';
img_name = {'2092.jpg','17067.jpg','33039.jpg','56028.jpg','65019.jpg','101085.jpg','102061.jpg','113016.jpg','126039.jpg','140075.jpg','217090.jpg','296028.jpg'};
for ii=1:length(img_name)
img = im2double(rgb2gray(imread(img_name{ii})));
for jj=1:6
    load(['test_kernel',num2str(jj),'.mat'])
    blurry = convn(img, kernel, 'valid');
    blurry = im2double(uint8(blurry*255));
    blurry = blurry + noise_level * randn(size(blurry));
    blurry = im2double(uint8(blurry*255));
    imwrite(blurry,[folder 'Blurry',num2str(ii),'_',num2str(jj),'.png'])
end    
end

for ii=1:length(img_name)
img = rgb2gray(imread(img_name{ii}));
img = img(21:end-20,21:end-20);
imwrite(img,['img',num2str(ii),'_gt.png']);
end
