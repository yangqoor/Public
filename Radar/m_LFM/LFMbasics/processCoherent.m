%% ��λ��۴���
clc;close all;clear all;

c = 3e8;
RF = 35e9;
lambda = c/RF;
f0 = 70e6;       %��Ƶ  70MHz
fm = 40e6;       %������  40MHz
T = 500e-6;      %�����ظ�����  500
PRF = 1/T;
t = 0:1/fm:T-1/fm;
NT = length(t);    %һ�������еĲ�����������������
Tp = 50e-6;        %�������ʱ��  50us
tp = 0:1/fm:Tp-1/fm;
NTp = length(tp);
B = 10e6;         %��Ƶ����  10MHz
k = B/Tp;         %��Ƶб��=����/�������ʱ��
M = 128;            %����������/���������
A = 1;
fm1 = fm/4;
tp1 = 0:1/fm1:(Tp-1/fm1);
N_FFT = 2048;
f_x = -fm1/2:fm1/N_FFT:fm1/2-fm1/N_FFT;
t_x = 0:1/fm1:(N_FFT-1)/fm1;
h2 = zeros(1,N_FFT);
h2(1:length(tp1)) = 2^10*exp(j*pi*k*(tp1-(Tp/2)).^2);%������2^10��
H2 = round(fft(conj(h2),N_FFT));   %ƥ���˲�

R1 = 20000;        %Ŀ��1����
V1 = 20;           %Ŀ��1�ٶ�
R2 = 25000;        %Ŀ��2����
V2 = 14;           %Ŀ��2�ٶ�

fd1 = 2*V1/lambda; %������Ƶ��1
fd2 = 2*V2/lambda; %������Ƶ��1

echo1 = zeros(M,NT); %�ز�
tao1 = zeros(1,M);  %������
N_tao1 = zeros(1,M); %ȡ��
echo2 = zeros(M,NT); %�ز�
tao2 = zeros(1,M);  %������
N_tao2 = zeros(1,M); %ȡ��

echo = zeros(M,NT);
local_i = cos(2*pi*f0*t);   %����
local_q = -sin(2*pi*f0*t);    
lowpassFilter=round( 32768*( fir2(31,[0 0.325 0.325 1],[1 1 0 0]) ) ); %LPF������2^15��������������
t_fd = 0:(1/fm):(T*M-1/fm);

echo1_fd = exp(j*2*pi*fd1*t_fd); %Ŀ��1��M�����������������������
echo2_fd = exp(j*2*pi*fd2*t_fd); %Ŀ��2��M�����������������������

%%%%%ģ������Ŀ��ز�%%%%%
for m=1:1:M
    
    tao1(1,m)=2*(R1-V1*(m-1)*T)/c;
    N_tao1(1,m) = round(tao1(1,m)*fm);
    tao2(1,m)=2*(R2-V2*(m-1)*T)/c;
    N_tao2(1,m) = round(tao2(1,m)*fm);
    
    for n=1:1:NT
        if(n < N_tao1(1,m))
            echo1(m,n) = 0;
        elseif(( n>=N_tao1(1,m) ) & ( n<=(N_tao1(1,m)+NTp) ))
            echo1(m,n) = exp(j*pi*k*((1+2*V1/c)*t(n)-tao1(1,m)).^2)*exp(-j*2*pi*(f0-B/2)*tao1(1,m))*exp(j*2*pi*(f0-B/2)*t(n))*echo1_fd(1,n+(m-1)*NT);
        else
            echo1(m,n) = 0;
        end
        
         if(n < N_tao2(1,m))
            echo2(m,n) = 0;
        elseif(( n>=N_tao2(1,m) ) & ( n<=(N_tao2(1,m)+NTp) ))
            echo2(m,n) = exp(j*pi*k*((1+2*V2/c)*t(n)-tao2(1,m)).^2)*exp(-j*2*pi*(f0-B/2)*tao2(1,m))*exp(j*2*pi*(f0-B/2)*t(n))*echo2_fd(1,n+(m-1)*NT);
        else
            echo2(m,n) = 0;
        end
    end
    
%------��echo1(m,n)���������------%
     
    SNR1 = -5;  % �ź�1�������dB
    NOISE1=randn(1,NT);
    MEAN_NOISE1 = mean(NOISE1);
    
	for nn = 1:NT
        NOISE_WITHOUT_MEAN1(1,nn)=NOISE1(1,nn)-MEAN_NOISE1;
	end
    signal_power1 = (1/NT)*(sum((echo1(m,:).*conj(echo1(m,:)))));
    noise_variance1 = signal_power1 / ( 10^(SNR1/10) );
    std_noise_n1 = std(NOISE1);
    echo1(m,:) = (std_noise_n1/sqrt(noise_variance1))*echo1(m,:);
    echo1(m,:)=echo1(m,:)+(NOISE1+i*hilbert(NOISE1));
    
%------��echo1(m,n)��������� end------%
        
%------��echo2(m,n)���������------%
     
    SNR2 = 2;  % �ź�2�������dB
    NOISE2=randn(1,NT);
    MEAN_NOISE2 = mean(NOISE2);
    
     for nn = 1:NT
            NOISE_WITHOUT_MEAN2(1,nn)=NOISE2(1,nn)-MEAN_NOISE2;
     end
    signal_power2 = (1/NT)*(sum((echo2(m,:).*conj(echo2(m,:)))));
    noise_variance2 = signal_power2 / ( 10^(SNR2/10) );
    std_noise_n2 = std(NOISE2);
    echo2(m,:) = (std_noise_n2/sqrt(noise_variance2))*echo2(m,:);
    echo2(m,:)=echo2(m,:)+(NOISE2+i*hilbert(NOISE2));
    
%------��echo2(m,n)��������� end------%

    echo(m,:) = round( A*( echo1(m,:)+ echo2(m,:) ) );
    AD_data(m,:) = real( echo(m,:) );
    
 end
    
for m=1:1:M   
%%%%%DDC%%%%%
    I_data_local(m,:) = AD_data(m,:).*local_i;
    Q_data_local(m,:) = AD_data(m,:).*local_q;
    I_data_local_FIR(m,:)=filter(lowpassFilter,1,I_data_local(m,:));
    Q_data_local_FIR(m,:)=filter(lowpassFilter,1,Q_data_local(m,:));
%%%%%4����ȡ%%%%%
    para_I = [I_data_local_FIR(m,2:20000)];
    I_data_local_FIR_1_4(m,:)=para_I(1:4:end);
    para_Q = [Q_data_local_FIR(m,2:20000)];
    Q_data_local_FIR_1_4(m,:)=para_Q(1:4:end);
%%%%FFT%%%%%%
    DDC_I_data_out(m,:) = I_data_local_FIR_1_4(m,814:2861);
    DDC_Q_data_out(m,:) = Q_data_local_FIR_1_4(m,814:2861);
    DDC_data_out(m,:) = DDC_I_data_out(m,:) + j*DDC_Q_data_out(m,:);
    xk(m,:) = fft(DDC_data_out(m,:),N_FFT);  %%�ز��źŵ�Ƶ��
    xk_re(m,:) = real(xk(m,:));
    xk_im(m,:) = imag(xk(m,:));
%%%%%%%PC%%%%%%
      PC_data_fft(m,:) = H2.*xk(m,:)./(2^17);  
      PC_data_ifft(m,:) = ifft(PC_data_fft(m,:),N_FFT)./(2^8);
%%%%%%%%%%%%%%%
end

PC_data_ifft_cut = zeros(M,1080);

for m=1:1:M
    PC_data_ifft_cut(m,:) = PC_data_ifft(m,461:1540);
end

PC_data_ifft_CA = zeros(M,1080);

%%%%%%%��λ���%%%%%%%%

for l = 1:1:1080    %%�������ڽ�ȡ��Ч��1080��
    PC_data_ifft_CA(:,l) = (fft(PC_data_ifft_cut(:,l),M));  % ��ÿһ����FFT������λ���
end
t_x_ca_cut = 0:1/fm1:(1080-1)/fm1;
f_x_ca = -PRF/2:PRF/M:PRF/2-PRF/M;

%%%%%%%%%%%��ͼ%%%%%%%%%%%%%

figure(1),plot(f_x,xk_re(1,:));
title('�ز��ź�Ƶ��(�ź�1��SNR=-5,�ź�2��SNR=2,)');axis tight;
xlabel('Ƶ��/Hz','FontSize',12);ylabel('�źŷ���','FontSize',12);
plot(t_x,     db(abs(PC_data_ifft(1,:)/max(abs(PC_data_ifft(1,:))))));
title('��ѹ���ź�(�ź�1��SNR=-5,�ź�2��SNR=2,)');axis tight;
xlabel('ʱ��/s','FontSize',12);ylabel('�źŷ���','FontSize',12);
figure(3),mesh(t_x_ca_cut,f_x_ca,abs(PC_data_ifft_CA));
title('ʱƵ��ά�ֲ�(�ź�1��SNR=-5,�ź�2��SNR=2,)');axis tight;
xlabel('ʱ��/s','FontSize',12);ylabel('Ƶ��/Hz','FontSize',12);zlabel('�źŷ���','FontSize',12);
