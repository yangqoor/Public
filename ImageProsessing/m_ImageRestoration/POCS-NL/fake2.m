im3=im_deblur;
im4=im3;
im4(im3<0.15)=im3(im3<0.15)*0.75;
figure;imshow(im4,[]);