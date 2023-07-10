
%%作者：
% -----------------------------第一题------------------------------------%
clear all;close all;clc;
%% ==========================实验参数===============================%
C=3e8;                       %光速
ae= 8494;                    %地球有效半径
lambda=0.03;                 %波长
taup=160e-6;                 %脉冲宽度
BW=1e6;                      %调频带宽
mu=BW/taup;                  %调频系数
D=0.25;                      %天线孔径
Ae=0.25*pi*D^2;              %天线有效面积
G=4*pi*Ae/lambda^2;          %天线增益
RCS=1500;                    %目标RCS（雷达截面积）
k=1.38e-23;                  %玻尔兹曼常数
T=290;                       %标准噪声温度（开尔文）
F=3;                         %噪声系数(dB)
L=4;                         %系统损耗(dB)
Lp=5;                        %信号处理损失(dB)
N_CI=64;                     %相干脉冲积累数
Pt_CI=30;                    %64脉冲相干积累时发射功率
Pt =1;                       %发射的峰值功率
Ru=80000;                    %不模糊探测距离
theta_3dB=6;                 %天线波束宽度(角度)
PRT=800e-6;                  %搜索状态脉冲重复周期
Fs=2e6;                      %采样频率
Va=600;                      %导弹速度 m/s
Vs=5;                        %目标航速根据学号推算为 5m/s
alpha=30;                    %目标航向与弹轴方向夹角(角度)
beta=1;                      %目标偏离弹轴方向夹角(角度)
Rs=40000;                    %第七题中 目标距离根据学号计算为40km
nTr=fix(PRT*Fs);             %每个脉冲重复周期采样点 1600
nTe=fix(taup*Fs);            %匹配滤波点数   320
nTe=nTe+mod(nTe,2);          %匹配滤波点数取偶数
P_fa=10e-6;                  %虚警概率
phi0  = 10;                  %波束中心10°
Gt_dB = 0;                   %发射增益
Gr_dB = 0;                   %接收增益
B =10;                       %带宽MHz
D0=12.5;                     %检测因子

%% =========================1.1 模糊函数================================%%
%% 模糊函数图
eps=1e-10;                                           %防止奇异点出现
tau=-taup:taup/1600:taup-taup/1600;                  %tau轴的点数
fd=-BW:BW/1000:BW-BW/1000;                         
[X,Y]=meshgrid(tau,fd);
temp1=1-abs(X)./taup;
temp2=pi*taup*(mu*X+Y).*temp1+eps;
lfm=abs(temp1.*sin(temp2)./temp2);                   %模糊函数模值
figure(1);mesh(tau*1e6,fd*1e-6,lfm);                 %模糊函数图
xlabel('时延/us');ylabel('多普勒（fd)/MHz');title('|X(\tau,fd)|模糊函数图');grid on;
%% 画出距离模糊函数图
[m1,m2]=find(lfm==max(max(lfm)));                    %找到原点
figure(2);plot(tau,20*log10(lfm(m1,:)),'b');         %画出距离模糊函数图
axis([-160e-6 160e-6 -60 0]);
xlabel('\tau/us');ylabel('|X(\tau,0)|(dB)');title('|X(\tau,0)|距离模糊图');grid on;
%% 画出速度模糊函数图
figure(3);
plot(fd,20*log10(lfm(:,m2)),'b');                 %画出速度模糊函数图
axis([-1e6 1e6 -60 0]);
xlabel ('多普勒/Hz');ylabel ('模糊函数/dB');title('多普勒模糊图');

%% %画出-4dB等高线图
figure(4);contour(tau*1e6,fd*1e-6,lfm,[10^(-4/20),10^(-4/20)],'g');
xlabel('\tau/us');ylabel('fd/MHz');title('模糊函数的-4dB切割等高线图');
%% -4dB等高线图局部放大图
figure();
contour(tau*1e6,fd*1e-6,lfm,[10^(-4/20),10^(-4/20)],'g'); 
axis([-7,4,-0.02 ,0.05]);
xlabel('\tau/us');ylabel('fd/MHz');title('模糊函数的-4dB切割等高线图(局部放大)');
%% %计算-3dB时宽带宽
[I2,J2]=find(abs(20*log10(lfm)-(-3)) < 0.1)  ;
tau_3db=abs(tau(J2(end))-tau(J2(1)))*1e6  %96us
B_3db=abs(fd(I2(end))-fd(I2(1)))*1e-6     %0.6MHz
figure();
contour(tau*1e6,fd*1e-6,lfm,[10^(-3/20),10^(-3/20)],'g');
xlabel('\tau/us');ylabel('fd/MHz');title('模糊函数的-3dB切割等高线图');
%%
%% ==============================1.2 相干积累===================================%%
%% 64脉冲相干积累前后信噪比-距离关系曲线
N_pulse=theta_3dB/60/PRT;                              %计算积累脉冲数
R_CI=linspace(0+Ru/400,Ru,400);                        
SNR_1=10*log10(Pt_CI*taup*G^2*RCS*lambda^2)-10*log10((4*pi)^3*k*T.*(R_CI).^4)-F-L-Lp;
SNR_N=SNR_1+10*log10(N_CI);                            %相干积累后的SNR
figure(5);plot(R_CI*1e-3,SNR_1,'b',R_CI*1e-3,SNR_N,'--r');
axis([35,80,-10,30]);
title('64相干积累前后信噪比-距离关系曲线');
xlabel('距离/km');ylabel('SNR/dB');legend('相干积累前','相干积累后');grid on;
%% %威力图
R=[0:10:90]; %km 等斜距
phi=[0:0.1:90]'; % 仰角
xr_range=cos(phi/180*pi)*R; %km 等距线的x轴
yr_range=sin(phi/180*pi)*R; %km 等距线的y轴
Het=[5:5:30]; %km 等高度
xr_high=zeros(length(Het),length([min(Het):1:80]));
yr_high=zeros(length(Het),length([min(Het):1:80]));
for num_high=1:length(Het)
    r=[Het(num_high):1:80]; %km
    lenr_high(num_high)=length(r);
    phi_high=asin(Het(num_high)./r-r/ae/2)/pi*180; %rad 仰角
    xr_high(num_high,1:lenr_high(num_high))=cos(phi_high/180*pi).*r; %km 等高线的x轴
    yr_high(num_high,1:1:lenr_high(num_high))=sin(phi_high/180*pi).*r; %km 等高线的y轴
end
%-------------------------------等仰角线----------------------------------------%
r_ele=[0:1:80]; %km 等仰角线的距离离散
Lenr_ele=length(r_ele);
Phi=cat(1,[0:2:24]',[28:4:40]',[50 :10 :90]'); %degree 等仰角 
xr_ele=cos(Phi/180*pi)*r_ele; %km 等高线的x轴
yr_ele=sin(Phi/180*pi)*r_ele; %km 等高线的y轴
%-------------------------------威力图----------------------------------------%
phi=[0:0.1:90]; %degree 俯仰角离散
gf = exp(-1.3863*((phi-phi0)/10).^2); %高斯型方向图
Gt=gf*10^(Gt_dB/10); % 发射方向图
Gr=gf*10^(Gr_dB/10); % 接收方向图
Simin=-114+10*log10(B)+10*log10(F)+10*log10(D0); %dBm 灵敏度
R4=Pt*taup*Gt.*Gr*lambda^2*RCS/( (4*pi)^3*10^((Simin/10-3)*10^(L/10)) ); % 威力
Rcover=R4.^(1/4)/1000; %km 雷达威力图
Rcover=Rcover/max(Rcover)*60;
xr_cover=cos(phi/180*pi).*Rcover; %km 威力图的x轴
yr_cover=sin(phi/180*pi).*Rcover; %km 威力图的y轴
figure(6)
for num_range=1:length(R) % 等距线
    plot(xr_range(:,num_range),yr_range(:,num_range),'g-'),hold on
end
for num_high=1:length(Het) % 等高线
    plot(xr_high(num_high,1:lenr_high(num_high)),yr_high(num_high,1:lenr_high(num_high)),'k-'),hold on
end
num_text=zeros(1,length(Phi));
for num_ele=1:length(Phi) % 等仰角线
    for m=1:Lenr_ele
        if (xr_ele(num_ele,m)<70 && xr_ele(num_ele,m+1)>=70) || (yr_ele(num_ele,m)<22 && yr_ele(num_ele,m+1)>=22)
            num_text(num_ele)=m;
            break;
        end
    end
    plot(xr_ele(num_ele,:),yr_ele(num_ele,:),'b-'),hold on
    
end

plot(xr_cover,yr_cover,'r','LineWidth',2)
title('雷达威力图')
xlabel('距离（km）'),ylabel('高度（km）')
axis([0 70 0 22])                    %设置坐标轴最大值
%对等仰角线做标注
text(71,yr_ele(1,num_text(1)),'0^o')
text(71,yr_ele(2,num_text(2)),'2^o')
text(71,yr_ele(3,num_text(3)),'4^o')
text(71,yr_ele(4,num_text(4)),'6^o')
text(71,yr_ele(5,num_text(5)),'8^o')
text(71,yr_ele(6,num_text(6)),'10^o')
text(71,yr_ele(7,num_text(7)),'12^o')
text(71,yr_ele(8,num_text(8)),'14^o')
text(71,yr_ele(9,num_text(9)),'16^o')
text(xr_ele(10,num_text(10)),22.5,'18^o')
text(xr_ele(11,num_text(11)),22.5,'20^o')
text(xr_ele(12,num_text(12)),22.5,'22^o')
text(xr_ele(13,num_text(13)),22.5,'24^o')
text(xr_ele(14,num_text(14)),22.5,'28^o')
text(xr_ele(15,num_text(15)),22.5,'32^o')
text(xr_ele(16,num_text(16)),22.5,'36^o')
text(xr_ele(17,num_text(17)),22.5,'40^o')
text(xr_ele(18,num_text(18)),22.5,'50^o')
text(xr_ele(19,num_text(19)),22.5,'60^o')
text(xr_ele(20,num_text(20)),22.5,'70^o')
text(xr_ele(21,num_text(21)),22.5,'80^o')
text(xr_ele(22,num_text(22)),22.5,'90^o')
%% ===============================1.3 匹配滤波函数===============================%%
PluseWidth = 160e-6;           %%脉冲宽度
Fs = 2e6;                      %%采样率
Br = 1e6;                      %%调频带宽
gama = Br/PluseWidth;           %%调制系数
tp_nrn = floor(PluseWidth*Fs/2)*2;%%向0取整--求采样点数
t = (-tp_nrn/2:tp_nrn/2-1)/Fs;    %%采样点的时间坐标
freq = linspace(-0.5*Fs,0.5*Fs,tp_nrn);
x = exp(1j*pi*gama*t.^2);  %%LFM
h = conj(fliplr(x));       %%匹配滤波器
h1 = h .* taylorwin(tp_nrn,4,-35).';%-35dB泰勒窗,频域也相当于加窗
h2 = h .* hamming(tp_nrn).';
N = (length(x)+length(x));%保留较大弃置区
H = fft(h,N);
H1 = fft(h1,N);
H2 = fft(h2,N);
y = ifft(fft(x,N).*H);
y = y/max(y);
y1 = ifft(fft(x,N).*H1);
y1 = y1/max(y1);
y2 = ifft(fft(x,N).*H2);
y2 = y2/max(y2);
tt = linspace(0,2*PluseWidth,N);
tt = tt*1000000;
%% 匹配函数实部和虚部
figure;
plot(t,real(h),'r',t,imag(h),'b--');
xlabel('时间/s');ylabel('幅度');title('匹配函数实部和虚部');
axis([-80e-6 80e-6 -inf inf]);
grid on;
figure;
plot(freq,abs(fftshift(fft(h))));
xlabel('频率/Hz');ylabel('幅度');title('匹配函数频谱');
axis tight;grid on;%%使坐标轴的最大最小值和你的数据范围一致
%% 脉压结果
figure;
plot(tt,20*log10(abs(y)),'r',tt,20*log10(abs(y1)),'g',tt,20*log10(abs(y2)),'k');
xlabel('时间/us');ylabel('归一化幅值/dB');title('脉压结果');
legend('不加窗','taylorwin','Hamming');
axis([-inf inf -60 0]);
grid on; 
%%  加窗细节对比
figure();
plot(tt,20*log10(abs(y)),'r',tt,20*log10(abs(y1)),'g',tt,20*log10(abs(y2)),'k');
axis([150 170 -60 0]);
xlabel('时间/us');ylabel('归一化幅值/dB');title('脉压结果');
legend('不加窗','taylorwin','Hamming');
clear N
%%
%%============================= 产生M序列 ================================%%
primpoly(7,'all');                %%7阶M序列的所有本原多项式
fbconnection = [1 0 0 0 0 0 1];   %移位寄存器的初始状态
n = length(fbconnection);
N = 2^n-1;
register = [zeros(1,n-1) 1];  
mseq(1) = register(n);
for i = 2:N
    newregister(1) = mod(sum(fbconnection.*register),2);%%取模
    for j = 2:n
        newregister(j) = register(j-1);%%register(1,n-1)
    end
    register = newregister;
    mseq(i) = register(n);
end
mseq = 2*mseq-1;
clear N
%%
%% ========================== M序列脉压 =========================%%
code = mseq;
Tp0 = 1e-6;%%每个码元的脉冲宽度
Ts = 1/Fs;
R0 = [40e3 60e3 80e3];
Vr = [0 50 500];
SNR = [10 10 10];
Rmin = 30e3;%%假定解调下来的信号以30km位置为参考  %%采样的最小距离
Rrec = 150e3;%%接收距离窗的大小
bos = 2*pi/0.03;
M = round(Tp0/Ts);%%每个码元内的采样点数
code2 = kron(code,ones(1,M));%扩展码元覆盖时间，保证整个脉冲被M序列码均匀调制
C = 3e8;
NR1 = 2^nextpow2(2*Rrec/C/Ts); %距离窗内对应的采样点数  
M2 = M*length(code);           %一个脉冲所占单元数
t1 = (0:M2-1)*Ts;              %遍历近似一个脉宽的
sp = (0.707*(randn(1,NR1)+1j*randn(1,NR1)));%距离窗内加噪
%%添加目标信息
for k = 1:length(R0)
    NR = fix(2*(R0(k)-Rmin)/C/Ts);%%向零取整  转换为采样点
    Ri = 2*(R0(k)-Vr(k)*t1);
    spt = (10^(SNR(k)/20))*exp(-1j*bos*Ri).*code2;%利用波数的概念
    sp(NR:NR+M2-1) = sp(NR:NR+M2-1)+spt;
end
rr = linspace(Rmin,Rmin+Rrec,length(sp))/1000;%不完全对应
rr_1 = linspace(Rmin,Rmin+Rrec,length(sp)+254);
spf = fft(sp,NR1+254);%直接取信号的长度，匹配滤波器长度忽略   长度为2048
Wf_t = fft(conj(fliplr(code2)),NR1+254);%做时间反折          长度为254
y = abs(ifft(spf.*Wf_t,NR1+254));
result = y(255:254+NR1);
%% 码长为127的M序列
figure;
plot(t1*1e6,real(code2));%%转化单位为微秒
grid on;
xlabel('时间/us');ylabel('匹配函数实部/V');title('码长为127的M序列');
%% 回波信号实部
figure;
plot(rr,real(sp));
grid on;
xlabel('距离/km');ylabel('回波信号实部/V');title('回波信号');
%% 速度为[0,50,100]m/s的脉压结果
figure;
plot(rr,20*log10(abs(result)));
grid on;
xlabel('距离/km');ylabel('脉压输出/dB');title('速度为[0,50,100]m/s的脉压结果');
axis([30 140 0 60]);
clear t1 R0 rr y

%% ================================1.4 加噪声信号处理========================================%%
%% 原始回波基带信号
Echo=zeros(1,fix(PRT*Fs));DelayNumber=fix(2*Ru/C*Fs);
Echo(1,(DelayNumber+1):(DelayNumber+length(x)))=x;%产生回波信号
V=Vs*cos((alpha+beta)/180*pi) ;                   %目标与导弹相对速度  目标航速Vs=5m/s
Signal_ad=2^8*(Echo/max(abs(Echo)));              %信号经过ad后 1*1600
t_N=0:1/Fs:N_CI*PRT-1/Fs;                         %N_CI=64  积累脉冲数 1*102400
Signal_N=repmat(Signal_ad,1,N_CI);                %64个周期回波(无噪声) 1*1600*64=102400
Signal_N=Signal_N.*exp(1j*2*pi*(2*V/lambda)*t_N); %引入多普勒频移 1*102400
Noise_N=1/sqrt(2)*(normrnd(0,2^10,1,N_CI*nTr)+1j*normrnd(0,2^10,1,N_CI*nTr));   % 噪声信号
Echo_N=Signal_N+Noise_N;                                                        %加噪声后的回波信号
Echo_N=reshape(Echo_N,nTr,N_CI);                                                %1600*64
figure(12);mesh((0:nTr-1)/Fs*C/2*1e-3,0:63,abs(Echo_N.'));title('原始回波基带信号');  %回波基带信号图像
xlabel('距离单元/Km');ylabel('多普勒单元');zlabel('幅度');grid on;
%% 距离维原始回波的基带信号
figure();
plot(abs(Echo_N));
%%  回波信号脉压
t=(-nTe/2:(nTe/2-1))/nTe*taup;
f=(-256:255)/512*(2*BW);
Slfm=exp(1j*pi*mu*t.*t);                    %线性调频信号
Ht=conj(fliplr(Slfm));    
Echo_N_fft=fft(Echo_N,2048);  
Ht=conj(fliplr(Slfm));    %回波信号FFT 2048*64
Hf_N=fft(Ht,2048);                                        %频域脉压系数
Hf_N=repmat(Hf_N.',1,N_CI);                               %脉压系数矩阵 2048*64
Echo_N_temp=ifft(Echo_N_fft.*Hf_N);                       %频域脉压，未去暂态点   1600*64
Echo_N_pc=Echo_N_temp(nTe:nTe+nTr-1,:);                   %去掉暂态点 
figure();
plot((0:nTr-1)/Fs*C/2*1e-3,20*log10(abs(Echo_N_pc)));
title('回波信号脉压');xlabel('距离单元/km');ylabel('幅度/dB');
%% 回波信号脉压局部图
figure();
plot((0:nTr-1)/Fs*C/2*1e-3,20*log10(abs(Echo_N_pc)));
axis([72 85 80 105]);
title('回波信号脉压局部图');
xlabel('距离单元/km');ylabel('幅度/dB');
%% 64脉冲相干积累结果
Echo_N_mtd=fftshift(fft(Echo_N_pc.'),1);%64脉冲相干积累和MTD
figure(14);mesh((0:nTr-1)/Fs*C/2*1e-3,(-32:31)/PRT/64,(abs(Echo_N_mtd)));
xlabel('距离/Km');ylabel('多谱勒频率/Hz');zlabel('幅度(dB)');grid on;title('64脉冲相干积累结果');set(gcf,'color',[1,1,1])
%% %等高图
figure;contour((0:nTr-1)/Fs*C/2*1e-3,(-32:31)/PRT/64,((abs(Echo_N_mtd))));
 axis([75 85 220 340]);
xlabel('距离/Km');ylabel('多谱勒频率/Hz');zlabel('幅度/dB');grid on;title('64脉冲相干积累等高线图');
%% 理论计算值
[index_i index_j]=find(abs(Echo_N_mtd)==max(max(abs(Echo_N_mtd)))); 
%找最大值多普勒单元对应的重复周期进行CFAR处理 index_i=1，index_j=1067 将多普勒fd和距离r转换成距离门
V_fd=2*V/lambda     ;                            %多普勒所的对应的多普勒频率 V=12.8575m/s 目标与导弹相对速度
mtd_fd=(index_i-1)/PRT/64 ;                      % 相参积累对应的多普勒频率 mtd_fd=0Hz
SNR_echo=20*log10(2^8/2^10)                      %原始回波基带信号信噪比   
SNR_pc=SNR_echo+10*log10(BW*taup)                %脉压后信噪比
SNR_ci=SNR_pc+10*log10(64) %64脉冲相干积累后信噪比 

%%
%% ----------------------------恒虚警--------------------------------% 
%% 恒虚警电平
N_mean=8;                                                                          %参考单元 M=8
N_baohu=4;                                                                         %保护单元 N=4
K0_CFAR=(1/P_fa)^(1/N_mean)-1         %K的值计算                                    %计算系数K=3.2170 
CFAR_data=abs(Echo_N_mtd(index_i,:));                                              %信号 1*1600，取最大值所在多普勒维数，index_i=1；
K_CFAR=K0_CFAR./N_mean.*[ones(1,N_mean/2) zeros(1,N_baohu+1) ones(1,N_mean/2)];    %恒虚警系数向量 1*13
CFAR_noise=conv(CFAR_data,K_CFAR);                                                 %恒虚警处理 13+1600-1=1612 
CFAR_noise=CFAR_noise(length(K_CFAR):length(CFAR_data)); 
%去暂态点 [13：:1600] 因为两边各存在4个参考单元和2个保护单元，所以实际进行CFAR的点是【7:1594】
figure(15);
plot(((N_mean+N_baohu)/2+1:nTr-(N_mean+N_baohu)/2)/Fs*C/2*1e-3,CFAR_noise,'r-.');  %恒虚警电平  【7:1594】
hold on;plot((0:nTr-1)/Fs*C/2*1e-3,CFAR_data,'b-');                                %信号
xlabel('距离/Km');ylabel('幅度');grid on;title('恒虚警处理');legend('恒虚警电平','信号电平');hold off

%%
hold on;plot((0:nTr-1)/Fs*C/2*1e-3,CFAR_data,'b-');  
axis([74 90 0 5e6]);%信号
xlabel('距离/Km');ylabel('幅度');grid on;title('恒虚警处理');legend('恒虚警电平','信号电平');
%hold off
%%