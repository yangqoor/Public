function [padimg, ypadpre, ypadpost,xpadpre, xpadpost] = myPadImgforDeblur_Laplacian(FBImg, kernel2d)
tic;
% [imgpyr, kerpyr, nlevel, scalefactor] = BuildPaddingPyramid(FBImg, kernel2d);
[imgpyr, padimgpyr, kerpyr, nlevel, scalefactor] = BuildPaddingPyramid(FBImg, kernel2d);

wt_ireg = 2e-3;
wt_breg = 0.2;

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
        cur_padimg = padarray(bimg, [ypadpre,xpadpre], 'replicate','pre');
        cur_padimg = padarray(cur_padimg, [ypadpost,xpadpost], 'replicate','post');
    else
        cur_padimg = imresize(pre_padimg, [imH, imW], 'bilinear');
%         cur_padimg = circshift(cur_padimg,[-ypad -xpad]);
        cur_padimg(1+ypadpre:end-ypadpost,1+xpadpre:end-xpadpost,:) = bimg;
%         cur_padimg(1:end-ypad,1:end-xpad,:) = bimg;
    end
    
    cur_ker = kerpyr{ilevel};
    ConstArgs = ComputePadConstArgsL(imH, imW, cur_ker);
 
    for ch = 1:size(cur_padimg,3)
        for i = 1:100
            cur_FImg = myDeconvL2_PreComp(cur_padimg(:,:,ch), cur_ker, wt_ireg, ConstArgs);
            cur_BImg = myReblurL2_PreCompL(cur_FImg, cur_ker, wt_breg, ConstArgs);
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
