%% 相参积累处理
clc;close all;clear all;

c = 3e8;
RF = 35e9;
lambda = c/RF;
f0 = 70e6;       %中频  70MHz
fm = 40e6;       %采样率  40MHz
T = 500e-6;      %脉冲重复周期  500
PRF = 1/T;
t = 0:1/fm:T-1/fm;
NT = length(t);    %一个脉冲中的采样点数，距离门数
Tp = 50e-6;        %脉冲持续时间  50us
tp = 0:1/fm:Tp-1/fm;
NTp = length(tp);
B = 10e6;         %调频带宽  10MHz
k = B/Tp;         %调频斜率=带宽/脉冲持续时间
M = 128;            %发射脉冲数/脉冲积累数
A = 1;
fm1 = fm/4;
tp1 = 0:1/fm1:(Tp-1/fm1);
N_FFT = 2048;
f_x = -fm1/2:fm1/N_FFT:fm1/2-fm1/N_FFT;
t_x = 0:1/fm1:(N_FFT-1)/fm1;
h2 = zeros(1,N_FFT);
h2(1:length(tp1)) = 2^10*exp(j*pi*k*(tp1-(Tp/2)).^2);%扩大了2^10倍
H2 = round(fft(conj(h2),N_FFT));   %匹配滤波

R1 = 20000;        %目标1距离
V1 = 20;           %目标1速度
R2 = 25000;        %目标2距离
V2 = 14;           %目标2速度

fd1 = 2*V1/lambda; %多普勒频率1
fd2 = 2*V2/lambda; %多普勒频率1

echo1 = zeros(M,NT); %回波
tao1 = zeros(1,M);  %多普勒
N_tao1 = zeros(1,M); %取整
echo2 = zeros(M,NT); %回波
tao2 = zeros(1,M);  %多普勒
N_tao2 = zeros(1,M); %取整

echo = zeros(M,NT);
local_i = cos(2*pi*f0*t);   %本振
local_q = -sin(2*pi*f0*t);    
lowpassFilter=round( 32768*( fir2(31,[0 0.325 0.325 1],[1 1 0 0]) ) ); %LPF扩大了2^15倍，并四舍五入
t_fd = 0:(1/fm):(T*M-1/fm);

echo1_fd = exp(j*2*pi*fd1*t_fd); %目标1在M个脉冲内引起的连续多普勒
echo2_fd = exp(j*2*pi*fd2*t_fd); %目标2在M个脉冲内引起的连续多普勒

%%%%%模拟生成目标回波%%%%%
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
    
%------在echo1(m,n)中添加噪声------%
     
    SNR1 = -5;  % 信号1的信噪比dB
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
    
%------在echo1(m,n)中添加噪声 end------%
        
%------在echo2(m,n)中添加噪声------%
     
    SNR2 = 2;  % 信号2的信噪比dB
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
    
%------在echo2(m,n)中添加噪声 end------%

    echo(m,:) = round( A*( echo1(m,:)+ echo2(m,:) ) );
    AD_data(m,:) = real( echo(m,:) );
    
 end
    
for m=1:1:M   
%%%%%DDC%%%%%
    I_data_local(m,:) = AD_data(m,:).*local_i;
    Q_data_local(m,:) = AD_data(m,:).*local_q;
    I_data_local_FIR(m,:)=filter(lowpassFilter,1,I_data_local(m,:));
    Q_data_local_FIR(m,:)=filter(lowpassFilter,1,Q_data_local(m,:));
%%%%%4倍抽取%%%%%
    para_I = [I_data_local_FIR(m,2:20000)];
    I_data_local_FIR_1_4(m,:)=para_I(1:4:end);
    para_Q = [Q_data_local_FIR(m,2:20000)];
    Q_data_local_FIR_1_4(m,:)=para_Q(1:4:end);
%%%%FFT%%%%%%
    DDC_I_data_out(m,:) = I_data_local_FIR_1_4(m,814:2861);
    DDC_Q_data_out(m,:) = Q_data_local_FIR_1_4(m,814:2861);
    DDC_data_out(m,:) = DDC_I_data_out(m,:) + j*DDC_Q_data_out(m,:);
    xk(m,:) = fft(DDC_data_out(m,:),N_FFT);  %%回波信号的频谱
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

%%%%%%%相参积累%%%%%%%%

for l = 1:1:1080    %%从脉冲内截取有效的1080点
    PC_data_ifft_CA(:,l) = (fft(PC_data_ifft_cut(:,l),M));  % 对每一列做FFT，即相参积累
end
t_x_ca_cut = 0:1/fm1:(1080-1)/fm1;
f_x_ca = -PRF/2:PRF/M:PRF/2-PRF/M;

%%%%%%%%%%%作图%%%%%%%%%%%%%

figure(1),plot(f_x,xk_re(1,:));
title('回波信号频谱(信号1的SNR=-5,信号2的SNR=2,)');axis tight;
xlabel('频率/Hz','FontSize',12);ylabel('信号幅度','FontSize',12);
plot(t_x,     db(abs(PC_data_ifft(1,:)/max(abs(PC_data_ifft(1,:))))));
title('脉压后信号(信号1的SNR=-5,信号2的SNR=2,)');axis tight;
xlabel('时间/s','FontSize',12);ylabel('信号幅度','FontSize',12);
figure(3),mesh(t_x_ca_cut,f_x_ca,abs(PC_data_ifft_CA));
title('时频二维分布(信号1的SNR=-5,信号2的SNR=2,)');axis tight;
xlabel('时间/s','FontSize',12);ylabel('频率/Hz','FontSize',12);zlabel('信号幅度','FontSize',12);
