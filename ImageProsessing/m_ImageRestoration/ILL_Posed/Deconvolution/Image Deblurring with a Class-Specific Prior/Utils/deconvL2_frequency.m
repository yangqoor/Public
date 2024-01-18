function [x]=deconvL2_frequency(I,filt1,we)
%note: size(filt1) is expected to be odd in both dimensions 

[n,m]=size(I);

filt1=fliplr(flipud(filt1));


Gx=fft2([-1 1],n,m);
Gy=fft2([-1; 1],n,m);
F=fft2(filt1,n,m);


A=conj(F).*F+we*(conj(Gx).*Gx+conj(Gy).*Gy);
b=conj(F).*fft2(I);

X=b./A;
x=ifft2(X);

hs1=floor((size(filt1,1)-1)/2);
hs2=floor((size(filt1,2)-1)/2);


x=x([end-hs1+1:end,1:end-hs1],[end-hs2+1:end,1:end-hs2],:);


return




