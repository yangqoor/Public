clear all
Wst=2*pi*1500;
Wp=2*pi*3000;
Ws=2*pi*15000;

% %第一步 求对应的数字频率
Ts=2*pi/Ws;
wp=Wp*Ts;
wst=Wst*Ts;

%第二步：计算理想高通滤波器的数字截止频率wc
wc=(wp+wst)/2;

%第三步：根据阻带衰减，确定窗函数，根据过渡带的宽度dw计算N
det=50;%可以选择海明窗hamming
dw=wp-wst;
N=ceil(6.6*pi/dw);

% N=N+1;%需要根据滤波器类型调整N的奇偶

tao=(N-1)/2;

%第四步：写出理想滤波器的冲激响应hd，写出窗函数wn，利用窗函数截取FIR滤波器的h
hd=zeros(1,N);
for n=0:N-1;
    if n~=tao
        hd(n+1)=1/(pi*(n-tao))*(sin((n-tao)*pi)-sin((n-tao)*wc));
    else
        hd(n+1)=1-wc/pi;
    end
end
wn=0.54-0.46*cos(2*pi*(0:(N-1))./(N-1));%窗函数wn
 h=hd.*wn;
% h=fir1(N-1,wc/pi,'high',hamming(N));
figure
freqz(h,1);%对数坐标显示幅度谱和相位谱
figure
[hx,w]=freqz(h,1);
plot(w/2/pi/Ts,abs(hx));%直角坐标显示幅度谱


