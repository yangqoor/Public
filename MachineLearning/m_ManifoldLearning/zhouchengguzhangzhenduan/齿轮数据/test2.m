close all;
clear all;
clc;
N=4096;
fs=2048;
t=(1:N)/fs;
[DATAfile,DATApath]=uigetfile('.txt','�����ź�');%��ʾһ��ȡ�ļ�����
FILENAME=[DATApath,DATAfile]
DATA=load(FILENAME);
yy=DATA(1:N);
y=yy-mean(yy);
%%%%%%%%%%%%%ԭʼ�ź�ʱ����%%%%%%%%%%%%%%
subplot(211) 
plot(t,y);
title('ʱ����ͼ');
xlabel('ʱ��/s');
ylabel('��ֵ'),grid on
%%%%%%%%%%%%%�ź�fftƵ�ײ���%%%%%%%%%%%%%%
subplot(212) 
f=(0:N/2-1)*fs/N;
y1=abs(fft(y))/N;
% y1=y1/max(y1);
plot(f,y1(1:N/2))
axis([0,200,0,0.6]);
title('fftƵ��ͼ');
xlabel('Ƶ��/HZ');
ylabel('��ֵ'),grid on