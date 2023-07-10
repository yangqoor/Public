clear all;
close all;
clc;
%%�������
N=4096;  %�źŵĲ�������
fs=1e8   %������Hz
t=(0:N-1)/fs;   %����ʱ��
f0=10e9;   %��ƵƵ��Hz
Tp=10e-6;   %������s
gamma=1e12 %���Ե�Ƶ��  B = gamma * Tp
tao=2e-5


%%����ز��ź� S
S=rectpuls(t-Tp/2-tao,Tp).*exp(j*pi*gamma*(t-Tp/2-tao).^2).*exp(-2j*pi*f0*tao);
figure(1)
plot((t*3e8)/2,real(S),'b','linewidth',2.5);
hold on
%plot((t*3e8)/2,imag(S),'r','linewidth',2.5);
grid on;
legend('�ز��ź�ʵ��,I·','�ز��ź��鲿��Q·')
title('�ز��źŵ�ʵ�����鲿')
xlabel('���룬��λm');
ylabel('�ز��źŷ���');

%%�ز�Ƶ�׷���
fft_Num=4096;
f=fs*(-2048:2047)/fft_Num;
Spetrum1=fftshift(fft(S,fft_Num));
figure(2)
plot(f,abs(Spetrum1),'linewidth',2.5);
grid on;
title('�ز��ź�Ƶ��')
xlabel('Ƶ�ʣ���λHZ');
ylabel('�ز��źŷ���');

%%����ο��ź�Sn
Sn=rectpuls(t-Tp/2,Tp).*exp(j*pi*gamma*(t-Tp/2).^2);
figure(3)
plot((t*3e8)/2,real(Sn),'b','linewidth',2.5);
hold on
%plot((t*3e8)/2,imag(Sn),'r','linewidth',2.5)
grid on;
legend('�ο��ź�ʵ��,I·','�ο��ź��鲿��Q·');
title('�ο��źŵ�ʵ�����鲿')
xlabel('���룬��λm');
ylabel('�ο��źŷ���');

%%�ο��ź�Ƶ�׷���
fft_Num=4096;
f=fs*(-2048:2047)/fft_Num;
Spetrum2=fftshift(fft(Sn,fft_Num));
figure(4)
plot(f,abs(Spetrum2),'linewidth',2.5);
grid on;
title('�ο��ź�Ƶ��')
xlabel('Ƶ�ʣ���λHZ');
ylabel('�ο��źŷ���');

%%�ο��źŹ������
gonge=conj(Spetrum2)
result=gonge.*Spetrum1;
fft_Num=4096;
f=fs*(0:fft_Num-1)/fft_Num;
Spetrum3=ifft(result,fft_Num);
figure(5)
plot((t*3e8)/2,abs(Spetrum3),'linewidth',2.5);
grid on;
title('��ѹ��ʱ����');
xlabel('���룬��λm');
ylabel('�źŷ���');
figure(6)
Spetrum4=20*log10(abs(Spetrum3));
plot((t*3e8)/2,Spetrum4,'linewidth',2.5);
grid on;
title('��ѹ��ʱ����,��λdB')
xlabel('���룬��λm');
ylabel('�źŷ���dB');

figure(7)
Spetrum5=max(abs(Spetrum3));
Spetrum6=Spetrum3/Spetrum5;
Spetrum6=20*log10(abs(Spetrum6));
plot((t*3e8)/2,Spetrum6,'linewidth',2.5);
grid on;
title('��һ������ѹ��ʱ����,��λdB')
xlabel('���룬��λm');
ylabel('�źŷ���dB');