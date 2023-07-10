% demo3

rgbImage=imread("peppers.png");
imagesc(rgb2gray(rgbImage))

colormap(slanCM('prism2')) 