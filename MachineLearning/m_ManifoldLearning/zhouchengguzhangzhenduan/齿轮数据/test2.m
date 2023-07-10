close all;
clear all;
clc;
N=4096;
fs=2048;
t=(1:N)/fs;
[DATAfile,DATApath]=uigetfile('.txt','输入信号');%显示一个取文件窗口
FILENAME=[DATApath,DATAfile]
DATA=load(FILENAME);
yy=DATA(1:N);
y=yy-mean(yy);
%%%%%%%%%%%%%原始信号时域波形%%%%%%%%%%%%%%
subplot(211) 
plot(t,y);
title('时域波形图');
xlabel('时间/s');
ylabel('幅值'),grid on
%%%%%%%%%%%%%信号fft频谱波形%%%%%%%%%%%%%%
subplot(212) 
f=(0:N/2-1)*fs/N;
y1=abs(fft(y))/N;
% y1=y1/max(y1);
plot(f,y1(1:N/2))
axis([0,200,0,0.6]);
title('fft频谱图');
xlabel('频率/HZ');
ylabel('幅值'),grid on