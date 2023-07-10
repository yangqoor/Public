%% =========================现代雷达系统分析与设计=======================%%
%%作者：
% -----------------------------第二题------------------------------------%
clear;close all;
%% 参数设置
load('IQ_data.mat');   %导入数据         
C = 3e8;               %光速           
lamda = 1.25;          %波长      
Pfa = 10e-6;           %恒虚警率        
Ts = 1e-6;             %采样周期          
Fs = 1/Ts;             %%采样率
BandWidth = 8e5;       %LFM带宽                    
PulseWidth = 420e-6;   %%脉冲宽度                  
gama = BandWidth/PulseWidth;       %% %LFM调频系数                  
AntennaSpacing  = 0.625;           %阵元间距半波长           
AntennaCount  = 20;                %20个主天线阵元
PulseCount  = 12;                  %脉冲数,并非方位向采样数
SampleNumber  = 3000;              %取样数

%% ===========================2.1 DBF =============================%%
theta0 = 0; %天线指向
DirectionVector = exp(1j*2*pi/lamda*(0:AntennaCount -1)'*AntennaSpacing *sin(theta0));%导向矢量20*1
Taylor_DBF = taylorwin(AntennaCount ,5,-25);%-25dB taylorwin
DirectionVector = DirectionVector.*Taylor_DBF;%方向向量
DBF_Result = zeros(SampleNumber ,PulseCount );
for i = 1:SampleNumber 
    for k = 1:PulseCount 
        DBF_Result(i,k) = IQ_mid(i,:,k)*DirectionVector;%3000*12
    end
end
figure;
plot(20*log10(abs(DBF_Result)));%%默认按列画
xlabel('距离单元');ylabel('信号幅度/dB');title('DBF结果（泰勒窗）');
axis([0 3000 80 170]);grid on;
grid on;

%% ===================== 2.2 脉压原始视频 =====================%%
SmpCount = floor(PulseWidth*Fs/2)*2;%脉冲时宽对应采样数 420
Smp_Time = (-SmpCount/2:SmpCount/2-1)'/Fs;%420*1
win_r = taylorwin(SmpCount,9,-35);%-35dB泰勒窗
h = exp(1j*pi*gama*Smp_Time.^2);%匹配滤波器，负调频？
h = h.*win_r;%加窗
H = fft(h,2^nextpow2(SampleNumber +length(h)));
PC_Result = zeros(2^nextpow2(SampleNumber ),PulseCount );
for i = 1:PulseCount 
    PC_Result(:,i) = ifft(fft(DBF_Result(:,i),2^nextpow2(SampleNumber +length(h))).*H);
end
figure;
plot(20*log10(abs(PC_Result(:,:))));
xlabel('距离单元');ylabel('信号幅度/dB');title('脉压结果（泰勒窗）');
axis([0 3000 80 180]);grid on;

%% ==========================2.3 zero_MTI ==========================%%
FilterOrder = 6;%动杂波滤波器阶数
T_Vector = [4.1e-3  4.3e-3  4.5e-3];%变T 187:200:213  %%周期
fr = 1/mean(T_Vector);
T_Count = length(T_Vector);%动杂波滤波器个数
zero_freq = [-1 -0.5 0 0.5 1];

f = [-100:0.1:100 101:1:2000];%频率范围,非均匀
Coeff_Count = FilterOrder-1;
tao_T = repmat(T_Vector,1,Coeff_Count);%产生A矩阵 计算权值
w = zeros(1,FilterOrder);
w(1) = 1;%w0=1
U = [1;zeros(Coeff_Count-1,1)];
A = zeros(Coeff_Count,Coeff_Count);
Ti = zeros(1,FilterOrder);
ww = zeros(T_Count,FilterOrder);
hd = 1;
%%求解权系数w
for uu = 1:length(zero_freq)
for m = 1:T_Count  %不同延迟状态的滤波输出状态011 101 110...
    tao = tao_T(m:m+Coeff_Count);
    Ti(1) = 0;
    for i = 1:Coeff_Count
        Ti(i+1) = sum(tao(1:i));
    end
    for k = 1:Coeff_Count
        A(k,1:Coeff_Count) = (Ti(2:end).^(k-1)) .* exp(-1*1i*2*pi*zero_freq(uu).*Ti(2:end));
    end
    w(2:end) = -w(1)*A\U;
    ww(m,:) = w;
    ww(m,:) = ww(m,:)/max(abs(ww(m,:)));%窗函数归一化
    hd0(m,:) = ww(m,:) * exp(-1j*2*pi*Ti'*f);
end
hd = hd .* hd0;
end
hd(m+1,:) = mean(abs(hd(1:m,:)));
hd = hd.^(1/length(zero_freq));
Hd = 20*log10(abs(hd));
figure;
plot(f,Hd);
xlabel('频率/Hz');ylabel('|H(f)|/dB');title('MTI滤波器幅频特性');
legend('T1:T2:T3','T2:T3:T1','T3:T2:T1','平均');    
axis([-100 2000 -inf 20]);grid on;
%% ============================2.4 MTI =============================%%
sig_mti = zeros(SampleNumber ,PulseCount -FilterOrder+1);%窗函数的长度为4或6，而一个波位的脉冲数为12
                                  %将sig中2^nextpow2(SampleNumber )-3000弃置
for k = 1:PulseCount -FilterOrder+1
    n = mod((k-1),3)+1;%默认波位中第一个脉冲按T1,T2,T3排列
    sig_mti(:,k) = PC_Result(1:SampleNumber ,k+(1:FilterOrder)-1) * ww(n,:).';
end
figure;
plot(20*log10(abs(sig_mti)));
xlabel('距离单元');ylabel('信号幅度/dB');title('MTI后原始视频');
axis([0 3000 80 180]);grid on;
%% ============================2.5 CFAR ============================%%
sig0 = mean(abs(sig_mti),2);%非相干积累
%%CFAR恒虚警
pro_cell = 1;                 %保护单元数
left_cell = 4;
right_cell = 4;               
K0 = (1/Pfa)^(1/(left_cell+right_cell))-1;% 比例系数K0
cfar = zeros(SampleNumber ,1);
%门限计算
for i = pro_cell+left_cell+1 : SampleNumber -right_cell-pro_cell
    cfar(i) = ( sum(sig0(i-pro_cell-left_cell:i-pro_cell-1,1)) ...%左
               +sum(sig0(i+pro_cell+1:i+pro_cell+right_cell,1)) ) ...%右
              ./(left_cell+right_cell)*K0;
end
figure; 
plot(20*log10(abs(sig0)),'b');hold on;

plot(20*log10(abs(cfar)),'r-.');
xlabel('距离单元');ylabel('信号幅度/dB');title('非相干积累原始视频，CFAR门限');
axis([500 3000 120 170]);
legend('原始信号','CFAR门限');
hold off;grid on;
%% CFAR 局部图
figure; 
plot(20*log10(abs(sig0)),'b');hold on;
plot(20*log10(abs(cfar)),'r-.');
xlabel('距离单元');ylabel('信号幅度/dB');title('非相干积累原始视频，CFAR门限');
axis([800 1350 120 170]);
legend('原始信号','CFAR门限');
hold off;grid on;
%%