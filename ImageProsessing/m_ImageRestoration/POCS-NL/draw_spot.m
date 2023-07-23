function im1=draw_spot(im,centr,radius)
[M,N]=size(im);
im1=zeros(M,N);
corx=1:M;cory=1:N;
[CX,CY]=meshgrid(corx,cory);
im1(( (CX-centr(1)).^2+ (CY-centr(2)).^2)<radius^2)=1;
im1=im1|im;
im1=double(im1);