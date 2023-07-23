function SRImage=FastD(Img_H,k,N)

%--- Sobel模板 ----
Sobel_H=[-1,0,1;-2,0,2;-1,0,1]/4; %Sobel求的梯度.水平梯度模板.
Sobel_V=[-1,-2,-1;0,0,0;1,2,1]/4;
%--- Gaussian模板 ----
GaussianXY=[1,2,1;2,4,2;1,2,1]/16;%%注意最后除以16.相当于论文中 f

% --- size ----
[m0,n0] = size(Img_H);
[m2 n2] = size(Sobel_H);
m1=m0+m2-1;
n1=n0+n2-1;

%--- FFT_Image ----
Img_H=im2double(Img_H);
FFT_Img_H=fft2(Img_H,m1 ,n1);



% --- FFT Gaussian ----
FFT_GaussianXY=fft2(GaussianXY,m1,n1);
% Gaus_Qx=conv2(GaussianXY,Sobel_H);
% Gaus_Qy=conv2(GaussianXY,Sobel_V);
% FFT_Gaus_Qx=fft2(Gaus_Qx,m1,n1);
% FFT_Gaus_Qy=fft2(Gaus_Qy,m1,n1);


%--- 图像的Soble梯度  FFT ----
Gx=conv2(Img_H,Sobel_H);
Gy=conv2(Img_H,Sobel_V);
FFT_Gx=fft2(Gx,m1,n1);
FFT_Gy=fft2(Gy,m1,n1);
FFT_Sobel_H=fft2(Sobel_H,m1,n1);
FFT_Sobel_V=fft2(Sobel_V,m1,n1);


%%%%%%%%%%%%
% for i=1:3
    FFT_Gaus=FFT_GaussianXY;
    FFT_Sobel_x=FFT_Sobel_H;
    FFT_Sobel_y=FFT_Sobel_V;
% end


%Complex conjgation
FFT_Sobel_x_Conj=conj(FFT_Sobel_x);
FFT_Sobel_y_Conj=conj(FFT_Sobel_y);
FFT_Optimal_Gaus_Conj=conj(FFT_Gaus);


FFT_Result=(FFT_Optimal_Gaus_Conj .* FFT_Img_H + k * FFT_Sobel_x_Conj .* FFT_Gx + k * FFT_Sobel_y_Conj .* FFT_Gy)./...
    (FFT_Optimal_Gaus_Conj .* FFT_Gaus + k * FFT_Sobel_x_Conj .* FFT_Sobel_x + k * FFT_Sobel_y_Conj .* FFT_Sobel_y+0.000001);


OutImg=255*ifft2(FFT_Result);
SRImage=OutImg(1:m0,1:n0);




