%%CS �㷨 by W&Z---------------------------------�ѿ�
%%================================================================
clear;clc;close all;
%%================================================================
%%Parameter--constant
C=3e8;                                   %propagation speed
%%Parameter--radar characteristics
Fc=10e9;                                  %carrier frequency 10GHz �����Ƶ��
lambda=C/Fc;                             %wavelength                
%%Parameter--target area
Xmin=-50;                                  %target area in azimuth is within[Xmin,Xmax]��λ��
Xmax=50;                                  
Yc=10000;                                %center of imaged area
Y0=500;                                  %target area in range is within[Yc-Y0,Yc+Y0]������
                                         %imaged width 2*Y0
%%Parameter--orbital information
V=100;                                   %SAR velosity 100 m/s ������
H=5000;                                  %height 5000 m
R0=sqrt(Yc^2+H^2);                       %Ŀ����ɻ����������        
%%Parameter--antenna
D=4;                                     %antenna length in azimuth direction��λ�����߳���
Lsar=lambda*R0/D;                        %�ϳɿ׾�����    
Tsar=Lsar/V;                             %�ϳɿ׾�ʱ��         

%% ��λ��
Ka=-2*V^2/lambda/R0;                      %��λ�������б��
Ba=abs(Ka*Tsar);                          %��λ������յ�Ƶ��Χ�������մ���
PRF=Ba;                                   %��λ��������Ƶ�ʾ͵��ڷ�λ�������Ƶ����ȣ����������Ӻζ���
PRT=1/PRF;                                %���㷽λ�������м��
ds=PRT;                                   %�����ظ�ʱ��
Nslow=ceil((Xmax-Xmin+Lsar)/V/ds);        %��ʱ��������������ǿ��ǵ���Ե������һ���ϳɿ׾��Ĳ���ʱ�䣨��λ��任ʱ��/�����ظ�ʱ�䣩
Nslow=2^nextpow2(Nslow);                  %for fft
sn=linspace((Xmin-Lsar/2)/V,(Xmax+Lsar/2)/V,Nslow);     %������λ���ź���ɢ���У���ʱ��Ϊ����
PRT=(Xmax-Xmin+Lsar)/V/Nslow;            %��λ��λ���
PRF=1/PRT;                               %����Ƶ��
ds=PRT;                                  %���������ʱ���� 

%% ������
Tr=5e-6;                                 %pulse duration 5us
Br=30e6;                                 %chirp frequency modulation bandwidth 30MHz
Kr=Br/Tr;                                %��Ƶб�ʣ���ɨƵ
Fsr=3*Br;                                %����Ƶ��
dt=1/Fsr;                                %�������
Rmin=sqrt((Yc-Y0)^2+H^2);                %��Сб��
Rmax=sqrt((Yc+Y0)^2+H^2+(Lsar/2)^2);     %���б��                                  
Nfast=ceil(2*(Rmax-Rmin)/C/dt+Tr/dt);    %��ʱ���������
Nfast=2^nextpow2(Nfast);                 %for fft
tm=linspace(2*Rmin/C,2*Rmax/C+Tr,Nfast); %�����������ź���ɢ���У���ʱ��Ϊ����                     
dt=(2*Rmax/C+Tr-2*Rmin/C)/Nfast;         %������������
Fsr=1/dt;                                %���������Ƶ�� 
%%
%%Parameter--resolution                      
DY=C/2/Br;                                %������ֱ���  
DX=D/2;                                   %��λ��ֱ���
%%Parameter--point targets
Ntarget=3;                                %������Ŀ��
%format [x, y, reflectivity]
Ptarget=[Xmin+10*DX,Yc+10*DY,1               
              Xmin+30*DX,Yc,1
              Xmin+20*DX,Yc+20*DY,1];     %Ŀ��Ͳο����λ�þ�����ɢ��ϵ��
%%================================================================
%%Generate the raw signal data
K=Ntarget;                                 %number of targets
N=Nslow;                                   %number of vector in slow-time domain  %��λ�� 
M=Nfast;                                   %number of vector in fast-time domain  %������
T=Ptarget;                                 %position of targets
Srnm=zeros(N,M);
for k=1:1:K
    sigma=T(k,3);                           %Ŀ��ɢ��ϵ��
    Dslow=sn*V-T(k,1);                      %������λ��㵽Ŀ��ķ�λ�����
    R=sqrt(Dslow.^2+T(k,2)^2+H^2);          %Ŀ���������λ���ϵĵ��б��   
    tau=2*R/C;                              %�ز���ʱ
    Dfast=ones(N,1)*tm-tau'*ones(1,M);      %���Ե�Ƶ����               
    phase=pi*Kr*Dfast.^2-(4*pi/lambda)*(R'*ones(1,M));%�ز���λ=�����ڶ����շ����������Ե�Ƶ����������Ҫ�Ӵ�����������������������������λ���ţ�
    Srnm=Srnm+sigma*exp(1i*phase).*(0<Dfast&Dfast<Tr).*((abs(Dslow)<Lsar/2)'*ones(1,M));
end
%%================================================================


%%
%% CS��������
f=linspace(-PRF/2,+PRF/2,Nslow);             %��λ��
fr=linspace(-Fsr/2,+Fsr/2,Nfast);            %������
r=tm/2*C;                                    %����
r_ref=sqrt(Yc^2+H^2);
CS_f=1./sqrt(1-(lambda*f/2/V).^2)-1;    %%%---------------��7.17ʽ��1/D-1
% Ks=Kr./( 1+Kr*r_ref*(2*lambda/C^2)*((lambda*f/2/V).^2)./(1-(lambda*f/2/V).^2).^1.5 ); %%--------��7.18ʽ��
Ks=Kr./( 1-Kr*r_ref*(2*lambda/C^2)*((lambda*f/2/V).^2)./(1-(lambda*f/2/V).^2).^1.5 ); %%--------��7.18ʽ��
R_ref=r_ref*(1+CS_f);                   %%------------ Rref/D
%% CS������chirp scaling�任
Srnm_xfft=fftshift(fft(fftshift(Srnm)));
% CS_phase=exp( -j*pi*(Ks.*CS_f)'*ones(1,M).*( ones(N,1)*tm-(2*R_ref/C)'*ones(1,M) ).^2 );%%----------��7.30ʽ��
CS_phase=exp( 1i*pi*(Ks.*CS_f)'*ones(1,M).*( ones(N,1)*tm-(2*R_ref/C)'*ones(1,M) ).^2 );%%----------��7.30ʽ��
Srnm_cs=Srnm_xfft.*CS_phase;                   %CS��λ�������

figure;
mesh(abs(Srnm_cs));
%% һ��RCMC�;���ѹ��

Srnm_yfft=fftshift(fft(fftshift(Srnm_cs.'))).';
% rmc_phase=exp( -j*pi*(ones(N,1)*fr.^2)./((Ks.*(1+CS_f))'*ones(1,M)) ).*exp( j*4*pi/C*(ones(N,1)*fr)*r_ref.*(CS_f'*ones(1,M)) );%%------��7.32ʽ��
rmc_phase=exp(1i*pi*(ones(N,1)*fr.^2)./((Ks.*(1+CS_f))'*ones(1,M)) ).*exp( 1i*4*pi/C*(ones(N,1)*fr)*r_ref.*(CS_f'*ones(1,M)) );%%------��7.32ʽ��
Srnm_rmc=Srnm_yfft.*rmc_phase;                 %�����㶯У�������ѹ��

figure;
mesh(abs(Srnm_rmc));

Srnm_yifft=fftshift(ifft(fftshift(Srnm_rmc.'))).';
r_sub=ones(N,1)*(r-r_ref).^2;
phase_cor=(4*pi/C^2*Ks.*(1+CS_f).*CS_f)'*ones(1,M).*r_sub;
% Srnm_xphase=exp( j*4*pi/lambda*ones(N,1)*r.*( sqrt(1-((lambda*f/2/V).^2)'*ones(1,M)) )-j*phase_cor-j*2*pi*C*ones(N,1)*tm/lambda   ); %%-----��7.34ʽ��        
Srnm_xphase=exp(1i*4*pi/lambda*ones(N,1)*r.*( sqrt(1-((lambda*f/2/V).^2)'*ones(1,M)) )-1i*phase_cor-1i*2*pi*C*ones(N,1)*tm/lambda   ); %%-----��7.34ʽ�� 
% Srnm_xphase=exp(1i*4*pi/lambda*ones(N,1)*r.*( sqrt(1-((lambda*f/2/V).^2)'*ones(1,M)) )+1i*phase_cor);
Srnm_cor=Srnm_yifft.*Srnm_xphase;             %��λѹ������λ����

figure;
mesh(abs(Srnm_cor));
f_xy=fftshift(ifft(fftshift(Srnm_cor))); 
%% =======================================================================
%%plot image
figure;
Ga=abs(f_xy);
%figure,mesh(Ga((200:300),(750:860)));axis tight;
mesh(Ga);
figure
imagesc(Ga)






