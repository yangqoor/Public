function u=display_inverse(im1)

im1=im1/max2(im1(:));
im2=imadjust(im1,[min2(im1),max2(im1)],[0,1]);
im2=1-im2;
u=im2;%u(u<0.2)=0;
figure;imshow(u,[]);