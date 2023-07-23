function Mse=mse1(im1,rim)
[m,n]=size(rim);
im1=im1(1:m,1:n);
Mse=sum(sum((im1-rim).^2));