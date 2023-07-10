
%%%低通滤波器设计
clear all

fs=5000;
Ts=1/fs;
% %第一步 求对应的数字频率
wp=0.4*pi;
wst=0.5*pi;
det=50;

%%确定滤波器单位冲击响应长度N
detw=abs(wp-wst);
m=1;
N=(m+1)*2*pi/detw;
N=N+1;%需要根据滤波器类型调整N的奇偶

N1=ceil(wp/2/pi*N);
N2=ceil(wst/2/pi*N);

Hd=zeros(1,N);
Hd(1:N1)=1;
Hd(N2:ceil(N/2))=0;
Hd(ceil((N1+N2)/2))=0.5;

%%%第一类采样方法
if mod(N-1,2)==0  
    for k=0:(N-1)/2
        H(k+1)=Hd(k+1).*exp(-1i*2*pi/N*k*(N-1)/2);
    end
    for k=(N+1)/2:N-1
        H(k+1)=Hd(N-k).*exp(-1i*2*pi/N*(N-k)*(N-1)/2);
    end
end

hn=ifft(H);
[h,ww] = freqz(hn,1,128);
figure
plot(ww/pi,abs(h));