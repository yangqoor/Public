function [x]=deconvSps(I,filt1,we,max_it)
%note: size(filt1) is expected to be odd in both dimensions 

if (~exist('max_it','var'))
   max_it  =200;
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
x=I;


dxf=[1 -1];
dyf=[1;-1];
dyyf=[-1; 2; -1];
dxxf=[-1, 2, -1];
dxyf=[-1 1;1 -1];


weight_x=ones(n,m-1);
weight_y=ones(n-1,m);
weight_xx=ones(n,m-2);
weight_yy=ones(n-2,m);
weight_xy=ones(n-1,m-1);


[x]=deconvL2_w(x(hfs_y1+1:n-hfs_y2,hfs_x1+1:m-hfs_x2),filt1,we,max_it,weight_x,weight_y,weight_xx,weight_yy,weight_xy);


w0=0.1;
exp_a=0.8;
thr_e=0.01; 

for t=1:2

  dy=conv2(x,fliplr(flipud(dyf)),'valid');
  dx=conv2(x,fliplr(flipud(dxf)),'valid');
  dyy=conv2(x,fliplr(flipud(dyyf)),'valid');
  dxx=conv2(x,fliplr(flipud(dxxf)),'valid');
  dxy=conv2(x,fliplr(flipud(dxyf)),'valid');


  weight_x=w0*max(abs(dx),thr_e).^(exp_a-2); 
  weight_y=w0*max(abs(dy),thr_e).^(exp_a-2);
  weight_xx=0.25*w0*max(abs(dxx),thr_e).^(exp_a-2); 
  weight_yy=0.25*w0*max(abs(dyy),thr_e).^(exp_a-2);
  weight_xy=0.25*w0*max(abs(dxy),thr_e).^(exp_a-2);
  
  [x]=deconvL2_w(I(hfs_y1+1:n-hfs_y2,hfs_x1+1:m-hfs_x2),filt1,we,max_it,weight_x,weight_y,weight_xx,weight_yy,weight_xy);

end


x=x(hfs_y1+1:n-hfs_y2,hfs_x1+1:m-hfs_x2);

return


