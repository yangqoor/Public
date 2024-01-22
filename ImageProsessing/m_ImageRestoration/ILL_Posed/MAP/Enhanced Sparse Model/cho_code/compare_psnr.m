function [ps]=compare_psnr(I1,I2)
[N3,N4]=size(I1);


maxshift=5;
shifts=[-5:0.25:5];




I2=I2(16:end-15,16:end-15);
I1=I1(16-maxshift:end-15+maxshift,16-maxshift:end-15+maxshift);
[N1,N2]=size(I2);
[gx,gy]=meshgrid([1-maxshift:N2+maxshift],[1-maxshift:N1+maxshift]);

[gx0,gy0]=meshgrid([1:N2],[1:N1]);
 


for i=1:length(shifts)
   for j=1:length(shifts)

     gxn=gx0+shifts(i);
     gyn=gy0+shifts(j);
     tI1=interp2(gx,gy,I1,gxn,gyn);
   
     ssdem(i,j)=sum(sum((tI1-I2).^2));
    
   end
end

ssde=min(ssdem(:));
ms = ssde/(N3*N4);
ps = 10*log10(1/ms);

