clear all;
close all;
clc;
%%�������
N=4096;  %�źŵĲ�������
fs=1e8   %������Hz
t=(0:N-1)/fs;   %����ʱ��
f0=10e9;   %��ƵƵ��Hz
Tp=10e-6;   %������s
b=1e12 %���Ե�Ƶ��
tao=2e-5
Tr=100e-6   %�����ظ�����
M=64    %�����ܸ���
v=60    %�ٶ�
R0=3000 %����
c=3e8   %����

%%����ز��ź� S

S=zeros(M,N);
Sn=zeros(M,N);
FFT_S=zeros(M,N);
Spetrum_FIN=zeros(M,N);
Spetrum1=zeros(M,N);
Spetrum2=zeros(M,N);
Spetrum3=zeros(M,N);
gonge=zeros(M,N);
Spetrum_lie=zeros(M,N);
fft_Num=4096;


%%��ѹ
for m=1:M

taom=2*(R0-m*Tr*v)/c;
S(m,:)=rectpuls(t-Tp/2-taom,Tp).*exp(1j*pi*b*(t-Tp/2-taom).^2).*exp(-2j*pi*f0*taom);%�ز��ź�
%%�ز�Ƶ�׷���
Sn(m,:)=rectpuls(t-Tp/2,Tp).*exp(j*pi*b*(t-Tp/2).^2);%�ο��ź�
Spetrum2(m,:)=fftshift(fft(Sn(m,:),fft_Num));
Spetrum1(m,:)=fftshift(fft(S(m,:),fft_Num));
gonge(m,:)=conj(Spetrum2(m,:)) ;   %�������
result(m,:)=gonge(m,:).*Spetrum1(m,:);
Spetrum_FIN(m,:)=ifft(result(m,:));

end
figure(1);



title('����������ѹ����ͼ��');
xlabel('���룬��λm');
ylabel('�ٶ�  m/s');

R=t.*c/2
imagesc(R,1:M,abs(Spetrum_FIN));
%%������FFT
Spetrum_lie=zeros(M,N);
for i2=1:N
    Spetrum_lie(:,i2)=fftshift(fft(Spetrum_FIN(:,i2),M));
end
figure(2);
datv=1/(2*Tr*M)*c/f0*(-M/2:M/2-1)
imagesc(R,datv,abs( Spetrum_lie));

[L,W]=find (abs(Spetrum_lie)==max(max(abs(Spetrum_lie))))%�������ֵ���ڵ��к���

%sprint('�����ٶ�Ϊ��3000m��60m/s')

title('��ά���������ƽ��')
xlabel('���룬��λm');
ylabel('�ٶ�  m/s');
datv(L)
R(W)