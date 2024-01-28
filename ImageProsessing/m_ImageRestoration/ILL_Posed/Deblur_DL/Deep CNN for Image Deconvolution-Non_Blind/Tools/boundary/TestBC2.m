%%  Test Kernel Estimation
% addpath('C:\Documents and Settings\xuli\Desktop\SV_DEBLUR\KernelEst');
% BIN = 'KernelEst_16bitpng.exe';
% IMPATH = './';
% close all;
clear;


%% read image & kerel
IMG_DIR = '..\data';
IMG_NAME = '1.bmp';
% IMG_NAME = 'ice_bat.jpg';
img = im2double((imread([IMG_DIR, '\', IMG_NAME])));
kerW = 31;
kerH = 31;
kernel2d = im2double(rgb2gray(imread('kernel4.bmp')));
kernel2d = imresize(kernel2d,[kerW, kerH]);
kernel2d(kernel2d<0)=0;
kernel2d = kernel2d/sum(kernel2d(:));
PSF = kernel2d;

%%
[FBImg, FImg] = GenBlurImg(img,PSF,0);

% tic;
% [padimg, ypadpre, ypadpost,xpadpre, xpadpost] = PadImgforDeblur(FBImg, PSF, 'ramp3');
% toc

% [imgpyr, szkerpyr, nlevel, scalefactor] = BuildBlurImagePyramid(FBImg,
% kerH, kerW);

% [padimg, ypadpre, ypadpost,xpadpre, xpadpost] = myPadImgforDeblur_Laplacian(FBImg, kernel2d);
[padimg, ypadpre, ypadpost,xpadpre, xpadpost] = myPadImgforDeblur1(FBImg, kernel2d);

if 0 
tic;
% [imgpyr, kerpyr, nlevel, scalefactor] = BuildPaddingPyramid(FBImg, kernel2d);
[imgpyr, padimgpyr, kerpyr, nlevel, scalefactor] = BuildPaddingPyramid(FBImg, kernel2d);

wt_ireg = 2e-3;
wt_breg = 0.1;

for ilevel=nlevel:-1:1
    bimg = imgpyr{ilevel};
    ypad = padimgpyr{ilevel}(1);
    xpad = padimgpyr{ilevel}(2);
    imH = padimgpyr{ilevel}(3);
    imW = padimgpyr{ilevel}(4);
    ypadpre = floor(ypad/2);
    ypadpost = ypad-ypadpre;           
    xpadpre = floor(xpad/2);
    xpadpost = xpad-xpadpre; 
        
    if ilevel == nlevel
        cur_padimg = padarray(bimg, [ypadpre,xpadpre], 0,'pre');
        cur_padimg = padarray(cur_padimg, [ypadpost,xpadpost], 0,'post');
    else
        cur_padimg = imresize(pre_padimg, [imH, imW], 'bilinear');
%         cur_padimg = circshift(cur_padimg,[-ypad -xpad]);
        cur_padimg(1+ypadpre:end-ypadpost,1+xpadpre:end-xpadpost,:) = bimg;
%         cur_padimg(1:end-ypad,1:end-xpad,:) = bimg;
    end
    
    cur_ker = kerpyr{ilevel};
    ConstArgs = ComputePadConstArgs(imH, imW, cur_ker);
 
    for ch = 1:size(cur_padimg,3)
        for i = 1:100
            cur_FImg = myDeconvL2_PreComp(cur_padimg(:,:,ch), cur_ker, wt_ireg, ConstArgs);
            cur_BImg = myReblurL2_PreComp(cur_FImg, cur_ker, wt_breg, ConstArgs);
            cur_padimg(:,:,ch) = cur_BImg;
            cur_padimg(1+ypadpre:end-ypadpost,1+xpadpre:end-xpadpost,ch)= bimg(:,:,ch);
%             cur_padimg(1:end-ypad,1:end-xpad,ch) = bimg(:,:,ch);
        end
    end
    
    % circular shift
    pre_padimg = cur_padimg;
%     if ilevel == nlevel
%         pre_padimg = circshift(cur_padimg,[-ypadpre -xpadpre]);
%     else
%         pre_padimg = cur_padimg;
%     end
    
    
end

% cur_padimg = circshift(cur_padimg,[ypadpre xpadpre]);
padimg = cur_padimg;
toc

end
%%
% methodlist = {'replicate','circular',
% 'symmetric','antisymmetric','zero','ramp','ramp2','edgetaper','edgetaper2
% '};

weight = 3e-4;
restore = zeros(size(padimg));
for ch = 1:size(padimg,3)
    restore(:,:,ch) =deconvL2_frequency(padimg(:,:,ch),kernel2d,weight);
end
FOV = restore(1+ypadpre:end-ypadpost,1+xpadpre:end-xpadpost,:);
PNSR_value = psnr(FOV*255,FImg*255);
disp(['L2 PSNR: ',num2str(PNSR_value)]);    

% methodlist = {'replicate','replicate2', 'comb1','antisymmetric','antisymmetric2','ramp','ramp2','edgetaper','edgetaper2'};
methodlist = {'ramp2','ramp3'};

Item_test = 3;
PSNR_List = zeros(Item_test, numel(methodlist));

for i = 1:numel(methodlist)
   
    method = methodlist{i};
    disp(['method :', method]);     
    
    if strcmp(method,'comb1') == 1
        [padimg, ypadpre1, ypadpost1,xpadpre1, xpadpost1] = PadImgforDeblur(FBImg, PSF, 'replicate');
        [padimg, ypadpre2, ypadpost2,xpadpre2, xpadpost2] = PadImgforDeblur(padimg, PSF, 'ramp2');
        ypadpre = ypadpre1+ypadpre2;
        ypadpost = ypadpost1+ypadpost2;
        xpadpre = xpadpre1+xpadpre2;
        xpadpost = xpadpost1+xpadpost2;
    else
        tic;
        [padimg, ypadpre, ypadpost,xpadpre, xpadpost] = PadImgforDeblur(FBImg, PSF, method);
        toc
    end

    %%
    restore_weiner = deconvwnr(padimg, PSF);
%     figure,imshow(restore_weiner);
%     title('weiner');
    cur_FImg_weiner = restore_weiner(1+ypadpre:end-ypadpost,1+xpadpre:end-xpadpost);
    PNSR_value = psnr(cur_FImg_weiner*255,FImg*255);
    disp(['Weiner PSNR: ',num2str(PNSR_value)]);    
    PSNR_List(1,i) = PNSR_value;



    addpath('Levin');
    weight = 3e-4;
    tic;
    restore_levin1 = deconvL2_frequency((padimg),PSF,weight);
    toc
%     conv_levin1 = circularconv(restore_levin1,PSF);   
    
    cur_FImg_levin = restore_levin1(1+ypadpre:end-ypadpost,1+xpadpre:end-xpadpost);
    PNSR_value = psnr(cur_FImg_levin*255,FImg*255);
    disp(['L2 PSNR: ',num2str(PNSR_value)]);
    PSNR_List(2,i) = PNSR_value;
    
%     figure,imshow(restore_levin1);
%     title('Levin1');
  

%     weight = 3e-4;
%     tic;
%     restore_levin2 = deconvL2((padimg),PSF,weight, 200);
%     toc
%     cur_FImg_levin2 = restore_levin2(1+ypadpre:end-ypadpost,1+xpadpre:end-xpadpost);
%     PNSR_value = psnr(cur_FImg_levin2*255,FImg*255);
%     disp(['My PSNR: ',num2str(PNSR_value)]);    
%     figure,imshow(restore_levin2);
%     title('Levin2');

    wt_reg = 0.0002;
    tic;
    restore_replace  = myDeconvRelpalce(padimg,PSF,wt_reg);
    toc
    cur_FImg_replace = restore_replace(1+ypadpre:end-ypadpost,1+xpadpre:end-xpadpost);
    PNSR_value = psnr(cur_FImg_replace*255,FImg*255);
    disp(['L1 PSNR: ',num2str(PNSR_value)]);    
    PSNR_List(3,i) = PNSR_value;
end
