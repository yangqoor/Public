close all; clear; clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                      三点目标(A,B,C)小斜视角下的机载雷达仿真
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rc=2e4;                                        %景中心斜距
Vr=150;                                        %雷达有效速度
Tr=2.5e-6;                                     %发射脉冲时宽
Kr=20e12;                                      %距离调频率
f0=5.3e9;                                      %雷达工作频率
deltaF=80;                                     %多普勒带宽
Fr=6e7;                                        %距离向采样率
Fa=100;                                        %方位向采样率
Na=256;                                        %距离线数
Nr=320;                                        %距离线采样点数
thetaC=3.5*pi/180;                             %波速中心斜视角
R0=Rc*cos(thetaC);                             %最短斜距 
etaC=-Rc*sin(thetaC)/Vr;                       %波束中心偏移时间
c=3e8;                                         %光速 
lamda=c/f0;                                    %波长
fc=2*Vr*sin(thetaC)/lamda;                     %多普勒中心频率
betaBW=deltaF*lamda/(2*Vr*cos(thetaC));        %方位向波束宽度
%%--------------------------------------------------------------------------------------------------------------
tau=linspace(2*Rc/c-0.5*Nr/Fr,2*Rc/c+0.5*Nr/Fr-1/Fr,Nr);        %距离时间
ftau=linspace(-Fr/2,Fr/2-Fr/Nr,Nr);                             %距离频率
eta=linspace(-0.5*Na/Fa,0.5*Na/Fa-1/Fa,Na);                     %方位时间
feta=linspace(fc-Fa/2,fc+Fa/2-Fa/Na,Na);                        %方位频率
%%--------------------------------------------------------------------------------------------------------------
Ntar=3;                                            %目标个数
Ptar=[R0-20,20,1;R0-20,100,0.7;R0+20,20,1];        %点目标（距离向坐标，方位向坐标，后向散射系数）
% Ntar=1;                                            %目标个数
% Ptar=[R0,0,1];                                     %点目标（距离向坐标，方位向坐标，后向散射系数）
%%--------------------------------------------------------------------------------------------------------------
S=zeros(Na,Nr);                                    %正交解调后的回波复信号
eta_m=eta'*ones(1,Nr);                             %扩充为矩阵
tau_m=ones(Na,1)*tau;                              %扩充为矩阵
for i=1:Ntar
    Reta=sqrt(Ptar(i,1)^2+(Vr*eta_m-Ptar(i,1)*tan(thetaC)-Ptar(i,2)).^2);    %斜距矩阵,波束前视
    Wa=sinc(0.886*atan((Vr*eta_m-Ptar(i,2))/Ptar(i,1))/betaBW).^2;           %双程波束方向图，波束前视
    S=S+Ptar(i,3)*Wa.*exp(1i*(pi*Kr*(tau_m-2*Reta/c).^2-4*pi*Reta/lamda)).*(abs(tau_m-2*Reta/c)<Tr/2); 
end
%%--------------------------------------------------------------------------------------------------------------
Smag=abs(S); %回波幅度
sm=max(max(Smag)); 
sn=min(min(Smag)); 
Smag=255*(Smag-sn)/(sm-sn);
figure();
subplot(3,2,1);
imagesc(tau*c/2,eta*Vr,-Smag),colormap(gray)
xlabel('斜距坐标(m)'),
ylabel('平台坐标(m)'),
title('(a)原始回波幅度');
%%--------------------------------------------------------------------------------------------------------------
%距离压缩
ht_rc=kaiser(Nr,2.5)'.*exp(1i*pi*Kr*(tau-2*Rc/c).^2).*(abs(tau-2*Rc/c)<Tr/2);
Hf_rc=conj(fftshift(fft(fftshift(ht_rc))));
Srf=fftshift(fft(fftshift(S,2),[],2),2);
Src_f=Srf.*(ones(Na,1)*Hf_rc);
Src_t=ifftshift(ifft(ifftshift(Src_f,2),[],2),2);
%%--------------------------------------------------------------------------------------------------------------
Smag=abs(Src_t); %距离压缩后的回波幅度
sm=max(max(Smag)); 
sn=min(min(Smag)); 
Smag=255*(Smag-sn)/(sm-sn);
subplot(3,2,2);
imagesc(tau*c/2,eta*Vr,-Smag),colormap(gray)
xlabel('斜距坐标(m)'),
ylabel('平台坐标(m)'),
title('(b)距离压缩后的信号幅度');
%%--------------------------------------------------------------------------------------------------------------
%距离徙动矫正
Srd=fftshift(fft(fftshift(Src_t,1)),1);                %方位fft
Mamb=round(fc/Fa);                                     %模糊数:Mamb*Fa-Fa/2<fc<Mamb*Fa+Fa/2
feta_fft=linspace(-Fa/2,Fa/2,Na);
shiftNum=-sum(feta_fft<fc-Mamb*Fa-Fa/2)+sum(feta_fft>fc-Mamb*Fa+Fa/2); %循环移位
Srd=circshift(Srd,shiftNum);
feta_m=feta'*ones(1,Nr);
UnitNum_rcm=lamda^2*Fr/8/Vr^2*tau_m.*feta_m.^2;
IntUnitNum_rcm=ceil(UnitNum_rcm);
DecUnitNum_rcm=round((IntUnitNum_rcm-UnitNum_rcm)*16);
UnitNumMax_rcm=max(max(abs(IntUnitNum_rcm)));
sinc_table=[-0.000 0.000 -0.000 0.000 1.000 -0.000 0.000 -0.000
    -0.003 0.010 -0.024 0.062 0.993 -0.054 0.021 -0.009;
    -0.007 0.021 -0.049 0.131 0.973 -0.098 0.040 -0.017;
    -0.012 0.032 -0.075 0.207 0.941 -0.134 0.055 -0.023;
    -0.016 0.043 -0.101 0.287 0.896 -0.160 0.066 -0.027;
    -0.020 0.054 -0.125 0.371 0.841 -0.176 0.074 -0.030;
    -0.024 0.063 -0.147 0.457 0.776 -0.185 0.078 -0.031;
    -0.027 0.071 -0.165 0.542 0.703 -0.185 0.079 -0.031;
    -0.030 0.076 -0.178 0.625 0.625 -0.178 0.076 -0.030;
    -0.031 0.079 -0.185 0.703 0.542 -0.165 0.071 -0.027;
    -0.031 0.078 -0.185 0.776 0.457 -0.147 0.063 -0.024;
    -0.030 0.074 -0.176 0.841 0.371 -0.125 0.054 -0.020;
    -0.027 0.066 -0.160 0.896 0.287 -0.101 0.043 -0.016;
    -0.023 0.055 -0.134 0.941 0.207 -0.075 0.032 -0.012;
    -0.017 0.040 -0.098 0.973 0.131 -0.049 0.021 -0.007;
    -0.009 0.021 -0.054 0.993 0.062 -0.024 0.010 -0.003;
    -0.000 0.000 -0.000 1.000 0.000 -0.000 0.000 -0.000;];
Srd_rcmc=zeros(Na,Nr);
ExpNum=2*UnitNumMax_rcm+10;
Srd_exp=zeros(Na,Nr+ExpNum);
Srd_exp(:,ExpNum/2+1:Nr+ExpNum/2)=Srd;
for i=1:Na
    for j=1:Nr 
        j_rcmc=j+ExpNum/2+IntUnitNum_rcm(i,j);
        Srd_rcmc(i,j)=Srd_exp(i,j_rcmc-4:j_rcmc+3)*sinc_table(DecUnitNum_rcm(i,j)+1,:)';
    end
end
%%--------------------------------------------------------------------------------------------------------------
Smag=abs(Srd); %距离多普勒域
sm=max(max(Smag)); 
sn=min(min(Smag)); 
Smag=255*(Smag-sn)/(sm-sn);
subplot(3,2,3);
imagesc(tau*c/2,feta,-Smag),colormap(gray)
xlabel('斜距坐标(m)'),
ylabel('方位向频率(HZ)'),
title('(c)方位fft后的信号幅度');
%%--------------------------------------------------------------------------------------------------------------
Smag=abs(Srd_rcmc); %RCMC后的距离多普勒域
sm=max(max(Smag)); 
sn=min(min(Smag)); 
Smag=255*(Smag-sn)/(sm-sn);
subplot(3,2,4);
imagesc(tau*c/2,feta,-Smag),colormap(gray)
xlabel('距离向坐标(m)'),
ylabel('方位向频率(HZ)'),
title('(d)RCMC后的信号幅度');
%%--------------------------------------------------------------------------------------------------------------
%Srd_rcmc=circshift(Srd_rcmc,Na-shiftNum);
S_rcmc=ifftshift(ifft(ifftshift(Srd_rcmc,1)),1); 
Smag=abs(S_rcmc); %RCMC后的信号幅度
sm=max(max(Smag)); 
sn=min(min(Smag)); 
Smag=255*(Smag-sn)/(sm-sn);
subplot(3,2,5);
imagesc(tau*c/2,eta*Vr,-Smag),colormap(gray)
xlabel('距离向坐标(m)'),
ylabel('平台坐标(m)'),
title('(e)RCMC后的信号幅度');
%%--------------------------------------------------------------------------------------------------------------

% PGA添加相位噪声
[m_rcmc,n_rcmc]=size(Srd_rcmc);
array_error=1:m_rcmc;
array_error=0.9*cos(array_error/10);
% phase_S=zeros(m_rcmc,1);
phase_S=array_error';
phase_S=exp(1j*phase_S);
temp_array=ones(1,n_rcmc);
phase_error_matrix=phase_S*temp_array;
Srd_rcmc=Srd_rcmc.*phase_error_matrix;




%方位压缩
Ka=2*Vr^2/lamda./(tau_m*c/2);
Hf_ac=exp(-1i*pi*feta_m.^2./Ka+1i*2*pi*tau_m*c/2*tan(thetaC)/Vr.*feta_m);
%Hf_ac=exp(-1i*pi*(feta_m).^2./Ka);
Sac_f=Srd_rcmc.*Hf_ac; %方位压缩
Sac_f=circshift(Sac_f,-shiftNum);
Sac_t=ifftshift(ifft(ifftshift(Sac_f,1)),1); %方位向IFFT
%%--------------------------------------------------------------------------------------------------------------
Smag=abs(Sac_t); %回波幅度
sm=max(max(Smag)); 
sn=min(min(Smag)); 
Smag=255*(Smag-sn)/(sm-sn);
subplot(3,2,6);
imagesc(tau*c/2,eta*Vr,-Smag),colormap(gray)
xlabel('距离向坐标(m)'),
ylabel('方位向波束中心坐标(m)'),
title('(f)方位压缩后的信号幅度');