% given an image, compute its psnr wrt gt and ssim

function [imgcrop, gtcrop, outpsnr, outssim]=psnr_ssim_img(img1,img2,border)
gtimg=img1;
%this border is how much to ignore

if ~exist('border','var')
    border=50;
    fprintf('####### setting to default border size 50. gtimg will be cropped...\n');
end
search_size=10; %plus minus this many pixels alignment

if (size(gtimg,3)>1)
    gtimg=rgb2gray(gtimg);
end
%figure;imshow(gtimg);
[hh ww]=size(gtimg);
gtcrop=gtimg(border+1:end-border,border+1:end-border);
 

[hhimg wwimg]=size(img2);
yoffset=(hhimg-hh)/2+border+1;
xoffset=(wwimg-ww)/2+border+1;
%right now chov1 is same size as gt...
imgcrop=findcrop(gtcrop,img2,yoffset,xoffset,search_size);

outpsnr=20*log10(1/sqrt(mean2((imgcrop-gtcrop).^2)));


outssim=ssim_index(round(255*imgcrop),round(255*gtcrop));

end