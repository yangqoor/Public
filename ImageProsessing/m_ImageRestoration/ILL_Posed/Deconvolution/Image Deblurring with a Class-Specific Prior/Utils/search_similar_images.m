path = 'F:\PAMI_Extra_results\Closest Training Images\';
ext = '*.png';

load('Bpfilters_90filters.mat');
Dir = dir([path ext]);

g = im2double(rgb2gray(imread('F:\Confusion_matrix_data\test\CMU\002_01_01_051_05.png')));

for top=1:length(Dir)-1
    It(top).I = im2double((imread([path Dir(top).name])));
    for i=1:size(filters,1)
        for j=1:size(filters,2)
            BP2 = abs(filters(i,j).bp).^2;
            t = It(top).I;
            It_bp(i,j,top).I = real(ifft2(imfilt_butterworth2(t , BP2)));
            
        end
    end
end


Dir = dir([pathDir ext]);
im_train = zeros(size(g, 1), size(g, 2) , 90);
ssim_val = zeros(90,4);
for top=1:4
    for i=1:size(filters,1)
        for j=1:size(filters,2)
            im_train_temp =  It_bp(i,j,top).I;
            im_train_temp = im2double(im_train_temp);
            ssim_val(i_num, top)     =  ssim(g, im_train_temp); % this is matlab function
        end
    end
end
[~, S_idx]= sort(ssim_val, 'descend');

