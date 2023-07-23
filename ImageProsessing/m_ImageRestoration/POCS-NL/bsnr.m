function s=bsnr(im,sigma)
aim=sum(im(:))/prod(size(im));
s1=   (im-aim).^2;
s2=sum(s1(:))/prod(size(im));

s=log10(s2/sigma)*10;