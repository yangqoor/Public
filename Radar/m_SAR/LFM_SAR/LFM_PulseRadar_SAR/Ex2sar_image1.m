%�ر�
close all;
clear all;
clc;

%Q1��������Ŀ��Ļز�
Tp = 2e-5;       %������
B  = 7e+7;       %�����źŴ���
fs = 1e+8;       %������
Lamda = 0.03125; %�ز�����
c = 3e+8;        %����
Rn = 1.52e+4;    %����������
Rmin = 1.5e+4;   %��ʼ��������
PRF = 700;       %�����ظ�Ƶ��
PRT = 1/PRF;     %�����ظ�����
Kr = B / Tp;     %��Ƶ��
fc = c / Lamda;  %�ز�Ƶ��
A = 1.5/180*pi;  %��λ�������
v0 = 100;        %�ɻ��ٶ�
targetX1 = 0;    %��1�ķ�λ������
targetX2 = 3;    %��2�ķ�λ������
Ls = 2*Rn*tan(A/2);       %�ϳɿ׾�����

%�����ź�
emit_t = 0:1/fs:Tp;         %�����źŹ۲�ʱ�䷶Χ
St_emit = exp(1i*pi*Kr*emit_t.^2);      %�����ź�

%nLs = floor(-Ls/(2*PRT*v0)):ceil(Ls/(2*PRT*v0));
x = -Ls/2:PRT*v0:Ls/2;          %ƽ̨�˶�λ��
Rnd = sqrt(x.^2 + Rn^2);        %ʵ�ʵ�б��
tnd = 2*Rnd/c;
ND = length(x);

echo_t = 2*Rn/c-Tp/2:1/fs:(max(Rnd)*2/c)+Tp;        %�ز��۲�ʱ�䷶Χ,��ʼʱ���ȥTp/2Ϊ�˷�ֹ�õ�������ѹ��ĵ�һ�������ݾ�Ϊ��ֵ��
                                                    %ʹ�û�������ͼ��ֻ�ܵõ�sinc�����һ��
len_echo = length(echo_t);                          %�ز��Ĺ۲����
echo_d = echo_t.*c/2;
St_back = zeros(ND,len_echo);                 %�ز��źž���

%Ŀ��1
for m = 1 : ND
    St_back(m,:) = rectpuls((echo_t-tnd(m)-Tp/2)/Tp).*exp(1i*pi*Kr*(echo_t-tnd(m)).^2).*exp(1i*2*pi*fc*(-tnd(m)));
end

real_St_back = real(St_back);           %ȡʵ��
%�ز����ݵĻҶ�ͼ
figure(1);
imagesc(echo_d,x,real_St_back); 
colormap(gray);
title('�ز�����ʵ���Ҷ�ͼ');
xlabel('����������/m');
ylabel('��λ������/m');

NFFT_D = 2^nextpow2(length(emit_t)+len_echo-1);                     %������fft�ĵ���
FSt_emit = fft(St_emit,NFFT_D);                                     %�����źŵ�FFT
F_filter = conj(FSt_emit);                                          %�ο��źŵ�fft��ʱ��ȡ���Ĺ���൱��Ƶ��ȡ����

%����������ѹ��
Dcompressed_signal = zeros(ND,len_echo);
for m = 1 : ND
    FSt_back = fft(St_back(m,:),NFFT_D);
    iFSt_back = ifft(FSt_back.*F_filter);
    Dcompressed_signal(m,:) = iFSt_back(1:len_echo);
end
abDcompressed_signal = abs(Dcompressed_signal);
figure(2);
imagesc(echo_d,x,abDcompressed_signal);    
colormap(gray);
title('������ѹ����Ļز��Ҷ�ͼ');
xlabel('����������/m');
ylabel('��λ������/m');

%��ȡһ�����ݻ�������ѹ����Ĳ��Σ��Ӷ���������ѹ�����������
figure(3);
row_compressed = abDcompressed_signal(2,:);                         %����һ�о���ѹ���������
plot(echo_t,row_compressed);                      
axis tight;
title('��������������ѹ����ĵ����ز�');
xlabel('��ʱ��/s');
ylabel('����');

[maxvalue,index] = max(abDcompressed_signal(2,:));                   %��������ֵ����

max_column = Dcompressed_signal(:,index);                            %ȡ����ֵ���ڵ���
%�Ȼ���ʵ���Ĳ���
figure(4);
subplot(211);
plot(x/v0,real(max_column));
axis tight;
title('��ֵ���ھ������ϵ�ʵ������');
xlabel('��ʱ��/s');
ylabel('����');
%�����������ʱ�����λ��
NFFT_max = 2^nextpow2(ND);                                          %����λ��ʱ��fft����
n_max = 0 : NFFT_max - 1;
FSt = fft(max_column,NFFT_max);                                     %���꣨��ֵ�����ڵľ�����
subplot(212);
plot(n_max/NFFT_max*PRF,phase(FSt));
axis tight;
title('��ֵ���ھ������ϵ���λ��');
xlabel('Ƶ��/Hz');
ylabel('��λ');

%��λ������ѹ��
NFFT_R = 2^nextpow2(2*ND-1);                                        %����λfft�ĵ��� 
fdr = -2*v0^2/(Lamda*Rn);                                           %���������Ե�Ƶб��
n = 1 : ND;
R_filter = exp(-1i*pi*fdr*(n*PRT).^2);                              %��λ��ƥ���˲��ĳ����Ӧ
FR_filter = fft(R_filter,NFFT_R);
RDcompressed_signal = zeros(ND,len_echo);
for nr = 1 : len_echo
    FRt = fft(Dcompressed_signal(:,nr),NFFT_R);
    Rcompressed_signal = ifft(FRt.*FR_filter.');
    RDcompressed_signal(:,nr) = Rcompressed_signal(1:ND);
end
abRDcompressed_signal = abs(RDcompressed_signal);
figure(5);
imagesc(echo_d,x,abRDcompressed_signal);    
colormap(gray);
title('����Ŀ�����');
xlabel('����������/m');
ylabel('��λ������/m');
axis([15190 15210 -15 15]);

%Q4�۲췽λ���������԰�
figure(6);
plot(x/v0,abRDcompressed_signal(:,index));         %��λ��ѹ��������壬�ǵ�index��
axis tight;
title('��άѹ����ķ�λ����Ȳ���');
xlabel('��ʱ��/s');
ylabel('����');

%Ŀ��1��Ŀ��2
x2 = (-Ls/2+targetX1):(PRT*v0):(Ls/2+targetX2);
Rnd1 = sqrt((x2-targetX1).^2+Rn^2);
Rnd2 = sqrt((x2-targetX2).^2+Rn^2);
tnd1 = 2*Rnd1/c;                           %Ŀ��1��ʱ���ӳ�����
tnd2 = 2*Rnd2/c;                           %Ŀ��2��ʱ���ӳ�����
ND2 = length(x2);
St_back_total = zeros(ND2,len_echo);       %�ز��źž���
for m = 1 : ND2
    St_back_total(m,:) = rectpuls((x2(m)-targetX1)/Ls)*rectpuls((echo_t-tnd1(m)-Tp/2)/Tp).*exp(1i*pi*Kr*(echo_t-tnd1(m)).^2).*exp(1i*2*pi*fc*(-tnd1(m)))+...             %Ŀ��1�Ļز�
                         rectpuls((x2(m)-targetX2)/Ls)*rectpuls((echo_t-tnd2(m)-Tp/2)/Tp).*exp(1i*pi*Kr*(echo_t-tnd2(m)).^2).*exp(1i*2*pi*fc*(-tnd2(m)));                %Ŀ��2�Ļز�
end

%����������ѹ��
Dcompressed_signal_total = zeros(ND2,len_echo);
for m = 1 : ND2
    FSt_back_total = fft(St_back_total(m,:),NFFT_D);
    compressed_signal_total = ifft(FSt_back_total.*F_filter);
    Dcompressed_signal_total(m,:) = compressed_signal_total(1:len_echo);
end

%����Ŀ��ز�����ѹ�����ʱ�����
figure(7);
imagesc(echo_d,x2,abs(Dcompressed_signal_total));       
colormap(gray);
title('����Ŀ��ز�����ѹ�����ʱ�����');
xlabel('����������/m');
ylabel('��λ������/m');

%��λ������ѹ��
NFFT_R2 = 2^nextpow2(2*ND2-1);                          %����Ŀ��ķ�λ��fft����
n2 = 1 : ND2;
R_filter_total = exp(-1i*pi*fdr*(n2*PRT).^2);
FR_filter_total = fft(R_filter_total,NFFT_R2);
RDcompressed_signal_total = zeros(ND2,len_echo);
for nr = 1 : len_echo
    FRt_total = fft(Dcompressed_signal_total(:,nr),NFFT_R2);
    Rcompressed_signal_total = ifft(FRt_total.*FR_filter_total.');
    RDcompressed_signal_total(:,nr) = Rcompressed_signal_total(1:ND2);
end

%����Ŀ��ز���άѹ�����ʱ�����
figure(8);
imagesc(echo_d,x2,abs(RDcompressed_signal_total));     
colormap(gray);
title('����Ŀ���άѹ�����ʱ�����');
xlabel('����������/m');
ylabel('��λ������/m');

