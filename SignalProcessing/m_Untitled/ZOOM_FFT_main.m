%细化FFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear 
clc
close all hidden
format long
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fni=input('细化FFT处理--输入数据文件名：','s');
fid=fopen(fni,'r');
sf=fscanf(fid,'%f',1);    %采样频率
fi=fscanf(fid,'%f',1);    %最小细化截止频率
np=fscanf(fid,'%d',1);    %放大倍数
nfft=fscanf(fid,'%d',1);  %FFT长度
fno=fscanf(fid,'%s',1);   %输入数据文件名
x=fscanf(fid,'%f',[1,inf]);%按行读入原始信号数据
status=fclose(fid);
%计算输入数据长度
nt=length(x);
%最大细化截止频率
fa=fi+0.5*sf/np;
%取大于nt且与nt最接近的2的整数次方为FFT长度
nf=2^nextpow2(nt);
%确定细化带宽的数据长度
na=round(0.5*nf/np+1);
%频移
%建立一个按1递增的向量
n=0:nt-1;
%建立单位旋转因子进行频移
b=n*pi*(fi+fa)/sf;
%乘以单位旋转引自进行频移
y=x.*exp(-i*b);
%频移后的低通滤波(频域滤波)
%FFT变换
b=fft(y,nf);
%正频率带桶内的元素赋值
a(1:na)=b(1:na);
%负频率带通内的元素赋值
a(nf-na+1:nf)=b(nf-na+1:nf);
%FFT变换
b=ifft(a,nf);
%重采样
c=b(1:np:nt);
%进行细化FFT变换
a=fft(c,nfft)*1/nfft;
%变换结果重新排序
y2=zeros(1,nfft/2);
%排列负频率段的数据
y2(1:nfft/4)=a(nfft-nfft/4+1:nfft);
%排列正频率段的数据
y2(nfft/4+1:nfft/2)=a(1:nfft/4);
n=0:(nfft/2-1);
%定义细化FFT频率向量
f2=fi+n*2*(fa-fi)/nfft;
%对输入数据作FFT用来变化比较
%FFT变换
y1=fft(x,nfft)*2/nfft;
f1=n*sf/nfft;
%定义与细化FFT频率向量相同的频率范围
ni=round(fi*nfft/sf+1);
na=round(fa*nfft/sf+1);
%绘制输入时程曲线图形
subplot(2,1,1);
t=0:1/sf:(nt-1)/sf;
nn=1:3000;
plot(t(nn),x(nn));
xlabel('时间（s）');
ylabel('幅值');
grid on
%在相同的频率范围下绘制幅频曲线图
subplot(212);
nn=ni:na;
plot(f1(nn),abs(y1(nn)),':',f2,abs(y2));
xlabel('频率(Hz)');
ylabel('幅值');
legend('普通','细化');
grid on
%打开文件输出细化后的数据
fid=fopen(fno,'w');
for k=1:nfft/2
    %每行输出3个实行数据，f为频率，y2的实和虚部
    fprintf(fid,'%f %f %f\n',f2(k),real(y2(k)),imag(y2(k)));
end
status=fclose(fid);

