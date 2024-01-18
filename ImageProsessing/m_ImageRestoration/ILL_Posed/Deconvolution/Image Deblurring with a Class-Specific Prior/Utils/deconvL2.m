function [x]=deconvL2(I,filt1,we,max_it)
%note: size(filt1) is expected to be odd in both dimensions 

if (~exist('max_it','var'))
   max_it=200;
end

[n,m]=size(I);




hfs1_x1=floor((size(filt1,2)-1)/2);
hfs1_x2=ceil((size(filt1,2)-1)/2);
hfs1_y1=floor((size(filt1,1)-1)/2);
hfs1_y2=ceil((size(filt1,1)-1)/2);
shifts1=[-hfs1_x1  hfs1_x2  -hfs1_y1  hfs1_y2];

hfs_x1=hfs1_x1;
hfs_x2=hfs1_x2;
hfs_y1=hfs1_y1;
hfs_y2=hfs1_y2;


m=m+hfs_x1+hfs_x2;
n=n+hfs_y1+hfs_y2;
N=m*n;
mask=zeros(n,m);
mask(hfs_y1+1:n-hfs_y2,hfs_x1+1:m-hfs_x2)=1;



tI=I;
I=zeros(n,m);
I(hfs_y1+1:n-hfs_y2,hfs_x1+1:m-hfs_x2)=tI; 
x=tI([ones(1,hfs_y1),1:end,end*ones(1,hfs_y2)],[ones(1,hfs_x1),1:end,end*ones(1,hfs_x2)]);



b=conv2(x.*mask,filt1,'same');



dxf=[1 -1];
dyf=[1;-1];


if (max(size(filt1)<25))
  Ax=conv2(conv2(x,fliplr(flipud(filt1)),'same').*mask,  filt1,'same');
else
  Ax=fftconv(fftconv(x,fliplr(flipud(filt1)),'same').*mask,  filt1,'same');
end


Ax=Ax+we*conv2(conv2(x,fliplr(flipud(dxf)),'valid'),dxf);
Ax=Ax+we*conv2(conv2(x,fliplr(flipud(dyf)),'valid'),dyf);



r = b - Ax;

for iter = 1:max_it  
     rho = (r(:)'*r(:));

     if ( iter > 1 ),                       % direction vector
        beta = rho / rho_1;
        p = r + beta*p;
     else
        p = r;
     end
     if (max(size(filt1)<25))
       Ap=conv2(conv2(p,fliplr(flipud(filt1)),'same').*mask,  filt1,'same');
     else  
       Ap=fftconv(fftconv(p,fliplr(flipud(filt1)),'same').*mask,  filt1,'same');
     end

     Ap=Ap+we*conv2(conv2(p,fliplr(flipud(dxf)),'valid'),dxf);
     Ap=Ap+we*conv2(conv2(p,fliplr(flipud(dyf)),'valid'),dyf);



     q = Ap;
     alpha = rho / (p(:)'*q(:) );
     x = x + alpha * p;                    % update approximation vector

     r = r - alpha*q;                      % compute residual

     rho_1 = rho;
end



x=x(hfs_y1+1:n-hfs_y2,hfs_x1+1:m-hfs_x2);
