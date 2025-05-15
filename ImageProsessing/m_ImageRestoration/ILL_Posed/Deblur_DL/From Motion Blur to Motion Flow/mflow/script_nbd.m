addpath('nbd_code/epllcode/')
addpath('nbd_code/')

%%
inpath = 'example/';
outpath = 'example/';

im_fn = [inpath, 'example1.png'];
[~, im_name, im_ext] = fileparts(im_fn);
mfstr = load([inpath, im_name, '_mfmap.mat']);

%%
y = imread(im_fn);
y = im2double(y);
mfmap = double(mfstr.mfmap);

%%
x_est = nbd_single(y, mfmap);

imwrite(x_est, [outpath, im_name, '_result.png']);

%%
mu = mfmap(:,:,1); mv = mfmap(:,:,2);
[mag, ori]= motion2magori(-mv, mu);
im_mfmap = draw_mfmap(double(y*255), mag, ori);

figure; subplot(1,3,1); imshow(y); title('Blurred image');
subplot(1,3,2); imshow(uint8(im_mfmap * 255)); title('Estimated motion flow');
subplot(1,3,3); imshow(x_est); title('Deblurring result');
