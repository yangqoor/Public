clear;
clc;
close all;
pathDir = 'D:\Fidelity\Human_Fidelity\Human_Intensity_Fidelity\images\New folder\';
ext='*.png';
Dir = dir([pathDir ext]);

pathDir_g = 'C:\Users\sanwar\Dropbox\ANU_PhD_Data\Debluring\All results\Results\HumansResults\groundtruth\New folder\';
ext_g='*.png';
Dir_g = dir([pathDir_g ext_g]);
dz = 1;
K = [0.05 0.05];
window = ones(8);
L = 1;
for dj=1:length(Dir)
    fprintf('image  = %d\n', dj);
    im =im2double(rgb2gray(imread([pathDir Dir(dj).name])));
    di = ceil(dj/8);
    
    if dz == 9
        dz =1;
    end
    
    g =  (im2double(rgb2gray(imread([pathDir_g Dir_g(di).name]))));
    ssim_r(di, dz) = ssim(g, im); 
%     PSNR_INITIAL_ESTIMATE = 10*log10(1/mean((im(:)-g(:)).^2));      
%     PSNR(di, dz) = PSNR_INITIAL_ESTIMATE;
    dz = dz + 1;
          
end
% mean(PSNR(:))
mean(ssim_r(:))