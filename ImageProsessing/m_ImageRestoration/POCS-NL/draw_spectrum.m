%% draw_spectrum
function a=draw_spectrum(x,threhold);
Fx=fft2(x);
Fx1=abs(Fx);
Fx2=10*log10(1+Fx1);

Fx2=Fx2/max2(Fx2);
Fx2=fftshift(Fx2);


if nargin==2
   [c1,c2]=size(x); 
   r=zeros(c1,c2);
   r(Fx2>threhold)=1;

   cor1=1:c1;
   cor2=1:c2;
   [Cor1,Cor2]=meshgrid(cor1,cor2);
   center1=round((c1+1)/2);
   center2=round((c2+1)/2);
   radius_fre=sqrt((Cor1-center1).^2+(Cor2-center2).^2);
   radius2=radius_fre.*r;
   R=max2(radius2);  %寻找最大的频谱半径，并保留这一区域，以之成图
   
   Fx2=Fx2.*(radius_fre<=R);
   
   
end
figure;
imshow(Fx2);
a=1;