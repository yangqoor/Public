 %==========================================================================
%Name:      spectrum_analysis.m
%Desc:      �Ը�˹�ź�Ϊ���������Ƶ�ס�˫�߹����ס����߹����ס�˫�߹������ܶȡ�
%           ���߹������ܶȣ������˹�źŵİ벨ȫ��FWHM=50ps�����ĵ�λ��2.5ns����
%Parameter: 
%Return:    
%Author:    yoyoba(stuyou@126.com)
%Date:      2015-4-28
%Modify:    2015-4-29
%=========================================================================
clc;
clear;
close all;
FWHM=50e-12;            %��˹�ź�FWHM��ȣ�Ϊ50ps
time_window=100*FWHM;   %��˹�źŵĲ������ڿ�ȣ���ֵ�����˸���Ҷ�任���Ƶ�ʷֱ���
Ns=2048;                %������
dt=time_window/(Ns-1);  %����ʱ����
t=0:dt:time_window;     %����ʱ��
gauss_time=exp(-0.5*(2*sqrt(2*log(2))*(t-2.5e-9)/FWHM).^2); %��˹���壬����λ��2.5ns����
plot(t*1e+9,gauss_time,'linewidth',1);
xlabel('Time/ns');
ylabel('Amplitude/V');
title('Gauss pulse');
%===========���¼���˫���ס�˫�߹����ס�˫�߹������ܶ�=================
gauss_spec=fftshift(fft(ifftshift(gauss_time)));    %����Ҷ�任�����ҽ���fftshift��λ������
gauss_spec=gauss_spec/Ns;   %��ʵ�ʵķ���ֵ��
df=1/time_window;               %Ƶ�ʷֱ���
k=floor(-(Ns-1)/2:(Ns-1)/2);    
% k=0:Ns-1;
double_f=k*df;   %˫��Ƶ�׶�Ӧ��Ƶ��


figure('NumberTitle','off','name','˫�߷�����'); %������
plot(double_f*1e-9,abs(gauss_spec),'linewidth',1);
xlabel('Frequency/GHz');
ylabel('Amplitude/V');
title('double Amplitude spectrum');


figure('NumberTitle','off','name','˫����λ��'); %��λ��
plot(double_f*1e-9,angle(gauss_spec),'linewidth',1);
xlabel('Frequency/GHz');
ylabel('Phase/rad');
title('double Phase spectrum');


figure('NumberTitle','off','name','˫�߹�����'); %������
double_power_spec_W=abs(gauss_spec).^2;                 %˫�߹����ף���λW��
double_power_spec_mW=double_power_spec_W*1e+3;          %˫�߹����ף���λmW��
double_power_spec_dBm=10*log10(double_power_spec_mW);   %˫�߹����ף���λdBm��
plot(double_f*1e-9,double_power_spec_dBm,'linewidth',1);
xlabel('Frequency/GHz');
ylabel('Power/dBm');
title('double Power spectrum');


figure('NumberTitle','off','name','˫�߹������ܶ�'); %�������ܶ�
double_power_specD_W=abs(gauss_spec).^2/(df);       %˫�߹������ܶ�,��λW/Hz
double_power_specD_mW=double_power_specD_W*1e+3;    %˫�߹������ܶ�,��λmW/Hz
double_power_specD_dBm=10*log10(double_power_specD_mW);%˫�߹������ܶ�,��λdBm/Hz
plot(double_f*1e-9,double_power_specD_dBm,'linewidth',1);
xlabel('Frequency/GHz');
ylabel('Power/(dBm/Hz)');
title('double power spectrum Density');


%==========���¼��㵥���ס����߹����׼����߹������ܶ�=========
gauss_spec=fft(ifftshift(gauss_time));  %���㵥��������fftshift
gauss_spec=gauss_spec/Ns;       %������ʵ�ķ���ֵ
single_gauss_spec=gauss_spec(1:floor(Ns/2));
single_f=(0:floor(Ns/2)-1)*df;


figure('NumberTitle','off','name','���߷�����'); %������
plot(single_f*1e-9,abs(single_gauss_spec),'linewidth',1);
xlabel('Frequency/GHz');
ylabel('Amplitude/V');
title('single Amplitude spectrum');


figure('NumberTitle','off','name','������λ��'); %��λ��
plot(single_f*1e-9,angle(single_gauss_spec),'linewidth',1);
xlabel('Frequency/GHz');
ylabel('Phase/rad');
title('single Phase spectrum');


figure('NumberTitle','off','name','���߹�����');%������
double_power_spec_W=abs(gauss_spec).^2;  
single_power_spec_W=2*double_power_spec_W(1:floor(Ns/2));   %���߹����ף���λW
single_power_spec_mW=single_power_spec_W*1e+3;              %���߹����ף���λmW��
single_power_spec_dBm=10*log10(single_power_spec_mW);       %˫�߹����ף���λdBm��
plot(single_f*1e-9,single_power_spec_dBm,'linewidth',1);  
xlabel('Frequency/GHz');
ylabel('Power/dBm');
title('single Power spectrum');


figure('NumberTitle','off','name','���߹������ܶ�');%�������ܶ�
double_power_specD_W=abs(gauss_spec).^2/(df);
single_power_specD_W=2*double_power_specD_W(1:floor(Ns/2));         %���߹������ܶȣ���λW/Hz
single_power_specD_mW=single_power_specD_W*1e+3;                    %���߹������ܶȣ���λmW/Hz
single_power_specD_dBm=10*log10(single_power_specD_mW);             %���߹������ܶȣ���λdBm/Hz
plot(single_f*1e-9,single_power_specD_mW,'linewidth',1);
xlabel('Frequency/GHz');
ylabel('Power/(dBm/Hz)');
title('single power spectrum density'); 