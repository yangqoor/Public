close all; clear; clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                      ����Ŀ��(A,B,C)Сб�ӽ��µĻ����״����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rc=2e4;                                        %������б��
Vr=150;                                        %�״���Ч�ٶ�
Tr=2.5e-6;                                     %��������ʱ��
Kr=20e12;                                      %�����Ƶ��
f0=5.3e9;                                      %�״﹤��Ƶ��
deltaF=80;                                     %�����մ���
Fr=6e7;                                        %�����������
Fa=100;                                        %��λ�������
Na=256;                                        %��������
Nr=320;                                        %�����߲�������
thetaC=3.5*pi/180;                             %��������б�ӽ�
R0=Rc*cos(thetaC);                             %���б�� 
etaC=-Rc*sin(thetaC)/Vr;                       %��������ƫ��ʱ��
c=3e8;                                         %���� 
lamda=c/f0;                                    %����
fc=2*Vr*sin(thetaC)/lamda;                     %����������Ƶ��
betaBW=deltaF*lamda/(2*Vr*cos(thetaC));        %��λ�������
%%--------------------------------------------------------------------------------------------------------------
tau=linspace(2*Rc/c-0.5*Nr/Fr,2*Rc/c+0.5*Nr/Fr-1/Fr,Nr);        %����ʱ��
ftau=linspace(-Fr/2,Fr/2-Fr/Nr,Nr);                             %����Ƶ��
eta=linspace(-0.5*Na/Fa,0.5*Na/Fa-1/Fa,Na);                     %��λʱ��
feta=linspace(fc-Fa/2,fc+Fa/2-Fa/Na,Na);                        %��λƵ��
%%--------------------------------------------------------------------------------------------------------------
Ntar=3;                                            %Ŀ�����
Ptar=[R0-20,20,1;R0-20,100,0.7;R0+20,20,1];        %��Ŀ�꣨���������꣬��λ�����꣬����ɢ��ϵ����
% Ntar=1;                                            %Ŀ�����
% Ptar=[R0,0,1];                                     %��Ŀ�꣨���������꣬��λ�����꣬����ɢ��ϵ����
%%--------------------------------------------------------------------------------------------------------------
S=zeros(Na,Nr);                                    %���������Ļز����ź�
eta_m=eta'*ones(1,Nr);                             %����Ϊ����
tau_m=ones(Na,1)*tau;                              %����Ϊ����
for i=1:Ntar
    Reta=sqrt(Ptar(i,1)^2+(Vr*eta_m-Ptar(i,1)*tan(thetaC)-Ptar(i,2)).^2);    %б�����,����ǰ��
    Wa=sinc(0.886*atan((Vr*eta_m-Ptar(i,2))/Ptar(i,1))/betaBW).^2;           %˫�̲�������ͼ������ǰ��
    S=S+Ptar(i,3)*Wa.*exp(1i*(pi*Kr*(tau_m-2*Reta/c).^2-4*pi*Reta/lamda)).*(abs(tau_m-2*Reta/c)<Tr/2); 
end
%%--------------------------------------------------------------------------------------------------------------
Smag=abs(S); %�ز�����
sm=max(max(Smag)); 
sn=min(min(Smag)); 
Smag=255*(Smag-sn)/(sm-sn);
figure();
subplot(3,2,1);
imagesc(tau*c/2,eta*Vr,-Smag),colormap(gray)
xlabel('б������(m)'),
ylabel('ƽ̨����(m)'),
title('(a)ԭʼ�ز�����');
%%--------------------------------------------------------------------------------------------------------------
%����ѹ��
ht_rc=kaiser(Nr,2.5)'.*exp(1i*pi*Kr*(tau-2*Rc/c).^2).*(abs(tau-2*Rc/c)<Tr/2);
Hf_rc=conj(fftshift(fft(fftshift(ht_rc))));
Srf=fftshift(fft(fftshift(S,2),[],2),2);
Src_f=Srf.*(ones(Na,1)*Hf_rc);
Src_t=ifftshift(ifft(ifftshift(Src_f,2),[],2),2);
%%--------------------------------------------------------------------------------------------------------------
Smag=abs(Src_t); %����ѹ����Ļز�����
sm=max(max(Smag)); 
sn=min(min(Smag)); 
Smag=255*(Smag-sn)/(sm-sn);
subplot(3,2,2);
imagesc(tau*c/2,eta*Vr,-Smag),colormap(gray)
xlabel('б������(m)'),
ylabel('ƽ̨����(m)'),
title('(b)����ѹ������źŷ���');
%%--------------------------------------------------------------------------------------------------------------
%�����㶯����
Srd=fftshift(fft(fftshift(Src_t,1)),1);                %��λfft
Mamb=round(fc/Fa);                                     %ģ����:Mamb*Fa-Fa/2<fc<Mamb*Fa+Fa/2
feta_fft=linspace(-Fa/2,Fa/2,Na);
shiftNum=-sum(feta_fft<fc-Mamb*Fa-Fa/2)+sum(feta_fft>fc-Mamb*Fa+Fa/2); %ѭ����λ
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
Smag=abs(Srd); %�����������
sm=max(max(Smag)); 
sn=min(min(Smag)); 
Smag=255*(Smag-sn)/(sm-sn);
subplot(3,2,3);
imagesc(tau*c/2,feta,-Smag),colormap(gray)
xlabel('б������(m)'),
ylabel('��λ��Ƶ��(HZ)'),
title('(c)��λfft����źŷ���');
%%--------------------------------------------------------------------------------------------------------------
Smag=abs(Srd_rcmc); %RCMC��ľ����������
sm=max(max(Smag)); 
sn=min(min(Smag)); 
Smag=255*(Smag-sn)/(sm-sn);
subplot(3,2,4);
imagesc(tau*c/2,feta,-Smag),colormap(gray)
xlabel('����������(m)'),
ylabel('��λ��Ƶ��(HZ)'),
title('(d)RCMC����źŷ���');
%%--------------------------------------------------------------------------------------------------------------
%Srd_rcmc=circshift(Srd_rcmc,Na-shiftNum);
S_rcmc=ifftshift(ifft(ifftshift(Srd_rcmc,1)),1); 
Smag=abs(S_rcmc); %RCMC����źŷ���
sm=max(max(Smag)); 
sn=min(min(Smag)); 
Smag=255*(Smag-sn)/(sm-sn);
subplot(3,2,5);
imagesc(tau*c/2,eta*Vr,-Smag),colormap(gray)
xlabel('����������(m)'),
ylabel('ƽ̨����(m)'),
title('(e)RCMC����źŷ���');
%%--------------------------------------------------------------------------------------------------------------

% PGA�����λ����
[m_rcmc,n_rcmc]=size(Srd_rcmc);
array_error=1:m_rcmc;
array_error=0.9*cos(array_error/10);
% phase_S=zeros(m_rcmc,1);
phase_S=array_error';
phase_S=exp(1j*phase_S);
temp_array=ones(1,n_rcmc);
phase_error_matrix=phase_S*temp_array;
Srd_rcmc=Srd_rcmc.*phase_error_matrix;




%��λѹ��
Ka=2*Vr^2/lamda./(tau_m*c/2);
Hf_ac=exp(-1i*pi*feta_m.^2./Ka+1i*2*pi*tau_m*c/2*tan(thetaC)/Vr.*feta_m);
%Hf_ac=exp(-1i*pi*(feta_m).^2./Ka);
Sac_f=Srd_rcmc.*Hf_ac; %��λѹ��
Sac_f=circshift(Sac_f,-shiftNum);
Sac_t=ifftshift(ifft(ifftshift(Sac_f,1)),1); %��λ��IFFT
%%--------------------------------------------------------------------------------------------------------------
Smag=abs(Sac_t); %�ز�����
sm=max(max(Smag)); 
sn=min(min(Smag)); 
Smag=255*(Smag-sn)/(sm-sn);
subplot(3,2,6);
imagesc(tau*c/2,eta*Vr,-Smag),colormap(gray)
xlabel('����������(m)'),
ylabel('��λ������������(m)'),
title('(f)��λѹ������źŷ���');