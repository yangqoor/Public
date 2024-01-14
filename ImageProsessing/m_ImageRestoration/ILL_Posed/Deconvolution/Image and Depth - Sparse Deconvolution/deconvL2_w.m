function [x]=deconvL2_w(I,filt1,we,max_it,weight_x,weight_y,weight_xx,weight_yy,weight_xy)

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

if (~exist('weight_x','var'))
  weight_x=ones(n,m-1);
  weight_y=ones(n-1,m);
  weight_xx=zeros(n,m-2);
  weight_yy=zeros(n-2,m);
  weight_xy=zeros(n-1,m-1);
end


tI=I;
I=zeros(n,m);
I(hfs_y1+1:n-hfs_y2,hfs_x1+1:m-hfs_x2)=tI; 
x=tI([ones(1,hfs_y1),1:end,end*ones(1,hfs_y2)],[ones(1,hfs_x1),1:end,end*ones(1,hfs_x2)]);



b=conv2(x.*mask,filt1,'same');



dxf=[1 -1];
dyf=[1;-1];
dyyf=[-1; 2; -1];
dxxf=[-1, 2, -1];
dxyf=[-1 1;1 -1];

if (max(size(filt1)<25))
  Ax=conv2(conv2(x,fliplr(flipud(filt1)),'same').*mask,  filt1,'same');
else
  Ax=fftconv(fftconv(x,fliplr(flipud(filt1)),'same').*mask,  filt1,'same');
end


Ax=Ax+we*conv2(weight_x.*conv2(x,fliplr(flipud(dxf)),'valid'),dxf);
Ax=Ax+we*conv2(weight_y.*conv2(x,fliplr(flipud(dyf)),'valid'),dyf);
Ax=Ax+we*(conv2(weight_xx.*conv2(x,fliplr(flipud(dxxf)),'valid'),dxxf));
Ax=Ax+we*(conv2(weight_yy.*conv2(x,fliplr(flipud(dyyf)),'valid'),dyyf));
Ax=Ax+we*(conv2(weight_xy.*conv2(x,fliplr(flipud(dxyf)),'valid'),dxyf));


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

     Ap=Ap+we*conv2(weight_x.*conv2(p,fliplr(flipud(dxf)),'valid'),dxf);
     Ap=Ap+we*conv2(weight_y.*conv2(p,fliplr(flipud(dyf)),'valid'),dyf);
     Ap=Ap+we*(conv2(weight_xx.*conv2(p,fliplr(flipud(dxxf)),'valid'),dxxf));
     Ap=Ap+we*(conv2(weight_yy.*conv2(p,fliplr(flipud(dyyf)),'valid'),dyyf));
     Ap=Ap+we*(conv2(weight_xy.*conv2(p,fliplr(flipud(dxyf)),'valid'),dxyf));


     q = Ap;
     alpha = rho / (p(:)'*q(:) );
     x = x + alpha * p;                    % update approximation vector

     r = r - alpha*q;                      % compute residual

     rho_1 = rho;
end



