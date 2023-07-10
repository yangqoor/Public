function image=myFSA(echo,Rs,fc,gama,delta_x,fs)
c=3e8;
j=sqrt(-1);
[Na,Nr]=size(echo);
kc=4*pi*fc/c;%距离中心波数
b=8*pi*gama/c^2;
DeltaX=delta_x;%方位向间隔
kx=2*pi*[-Na/2:Na/2-1]/DeltaX/Na;%方位波数
Ax=sqrt(1-kx.^2/kc^2);

Ys=[-Nr/2:Nr/2-1]/Nr*fs*(-c/2/gama);

Rb=Ys+Rs;
t_r=[-Nr/2/fs:1/fs:(Nr/2-1)/fs];%距离向时间
krDelta=4*pi*gama*(t_r)/c;

echokxkr=zeros(Na,Nr);%二维波数域矩阵
echokxr=zeros(Na,Nr);%方位波数域矩阵
%% FS
echokxkr=fftshift(fft(fftshift(echo)));
HFS=exp(j*(1-Ax.')*(krDelta.^2)./2./b);
H=exp(-j*kc*Rs);
echokxkr=echokxkr.*HFS.*H;
figure;imagesc(abs(echokxkr));title('变标完成，二维波数域');

%% 距离向IFFT，并乘以参考函数2，进行去RVP操作

echokxr=fftshift(ifft(fftshift(echokxkr.'))).';
 figure;imagesc(abs(echokxr));title('变标完成，方位波数、距离域');
HRVP=exp(-j*b/2*(1./Ax.')*(Ys.^2));
echokxr=echokxr.*HRVP;
figure;imagesc(abs(echokxr));title('RVP校正完成，方位波数、距离域');

%% 距离向FFT，并乘以参考函数3，进行IFS,SRC,RMC三项操作
echokxkr=fftshift(fft(fftshift(echokxr.'))).';
figure;imagesc(abs(echokxkr));

HIFS=exp(j*((Ax.').^2-Ax.')*krDelta.^2/2/b);
echokxkr=echokxkr.*HIFS;
echokxr=fftshift(ifft(fftshift(echokxkr.'))).';
figure;imagesc(abs(echokxr));title('逆变标完成，方位波数、距离域');

HRMC=exp(-j*(Ax.'.*Rs-Rs)*krDelta);
echokxkr=echokxkr.*HRMC;
echokxr=fftshift(ifft(fftshift(echokxkr.'))).';
figure;imagesc(abs(echokxr));title('RCMC完成，方位波数、距离域');

HSRC=exp(-j/2/(kc^3).*(kx.^2./Ax).'*(Rs.*krDelta.^2)).* ...
    exp(j/2/(kc^4).*(kx.^2./Ax.^2).'*(Rs.*krDelta.^3));
echokxkr=echokxkr.*HSRC;
figure;imagesc(abs(echokxkr));title('逆变标，RCM，SRC完成，二维波数域');

%% 距离向IFFT,得到距离压缩的结果，并乘以参考函数4，进行方位匹配
echokxr=fftshift(ifft(fftshift(echokxkr.'))).';
figure;imagesc(abs(echokxr));title('逆变标，RCMC，SRC完成，方位波数、距离域');

HAS=exp(j*kc.*Ax.'*Rb);
echokxr=echokxr.*HAS;
image=fftshift(ifft(fftshift(echokxr)));
figure,imagesc(abs(image));
title('方位压缩完成，时域成像结果');


end