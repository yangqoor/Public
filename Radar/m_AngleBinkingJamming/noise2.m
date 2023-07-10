% 接收机内部噪声模型
function nzsh=noise2(N0,tao,fs,t)
%% 程序
% 中放输出频率  需要改
fc=1e7;
% N0=k*T0*Bn*Nf;    % 接收机噪声的方差
N=sqrt(N0)*(randn(1,length(t))-j*randn(1,length(t)));
N_r=real(N.*exp(j*2*pi*fc*t));
% 窄带滤波器
wp=[9.6575e6,10.3425e6]/(fs/2);
ws=[9.5e6,10.5e6]/(fs/2);
Rp=1;
Rs=10;
[n,wn]=buttord(wp,ws,Rp,Rs);
[b,a]=butter(n,wn,'bandpass');
% freqz(b,a);
nzsh=filter(b,a,N_r);