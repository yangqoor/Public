%%================================================================
%%�ļ�����NearSAR.m
%%���ߣ���һ��
%%���ܣ��ϳɿ׾��״����������㷨��Ŀ����� 
%%================================================================
clear;clc;close all;
%%================================================================
%%��������
C=3e8;                            %����
%%�״����
Fc=1e9;                          %��Ƶ1GHz
lambda=C/Fc;                     %����
%%Ŀ���������
Xmin=0;                          %Ŀ������λ��Χ[Xmin,Xmax]
Xmax=50;                  
Yc=10000;                      %������������
Y0=500;                          %Ŀ�����������Χ[Yc-Y0,Yc+Y0]
                                       %������Ϊ2*Y0
%%�������
V=100;                            %SAR���˶��ٶ�100 m/s
H=5000;                          %�߶� 5000 m
R0=sqrt(Yc^2+H^2); %��̾���
seita = atan(Yc/H);
%%���߲���
D=4;                                %��λ�����߳���
Lsar=lambda*R0/D;   %SAR�ϳɿ׾����ȣ����ϳɿ׾��״����??�㷨��ʵ�֡�P.100
Tsar=Lsar/V;                   %SAR����ʱ��
%%��ʱ�������
Ka=-2*V^2/lambda/R0;    %������Ƶ���Ƶ��P.93
Ba=abs(Ka*Tsar);           %������Ƶ�ʵ��ƴ���
PRF=Ba;                         %�����ظ�Ƶ�ʣ�PRF��ʵΪ������Ƶ�ʵĲ����ʣ���Ϊ��Ƶ�ʣ����Ե���Ba.P.93
PRT=1/PRF;                   %�����ظ�ʱ��
ds=PRT;                         %��ʱ���ʱ�䲽��
Nslow=ceil((Xmax-Xmin+Lsar)/V/ds); %��ʱ��Ĳ�������ceilΪȡ�����������P.76��ͼ���  
Nslow=2^nextpow2(Nslow);              %nextpow2Ϊ���2���ݴκ���������Ϊfft�任��׼��
sn=linspace((Xmin-Lsar/2)/V,(Xmax+Lsar/2)/V,Nslow);%��ʱ�����ʱ�����
PRT=(Xmax-Xmin+Lsar)/V/Nslow;    %����Nslow�ı��ˣ�������Ӧ��һЩ����Ҳ��Ҫ���£����ڼ�С��
PRF=1/PRT;
ds=PRT;
%%��ʱ�����������
Tr=5e-6;                         %�������ʱ��5us
Br=30e6;                        %chirpƵ�ʵ��ƴ���Ϊ30MHz
Kr=Br/Tr;                        %chirp��Ƶ��
Fsr=2*Br;                        %��ʱ�����Ƶ�ʣ�Ϊ2���Ĵ���
dt=1/Fsr;                         %��ʱ��������
Rmin=sqrt((Yc-Y0)^2+H^2);
Rmax=sqrt((Yc+Y0)^2+H^2+(Lsar/2)^2);
Nfast=ceil(2*(Rmax-Rmin)/C/dt+Tr/dt);%��ʱ��Ĳ�������
Nfast=2^nextpow2(Nfast);                   %����Ϊ2���ݴΣ��������fft�任
tm=linspace(2*Rmin/C,2*Rmax/C+Tr,Nfast); %��ʱ�����ɢʱ�����
dt=(2*Rmax/C+Tr-2*Rmin/C)/Nfast;    %���¼��
Fsr=1/dt;
%%�ֱ��ʲ�������
DY=C/2/Br;                           %������ֱ���
DX=D/2;                                %��λ��ֱ���
%%��Ŀ���������
Ntarget=5;                            %��Ŀ�������
%��Ŀ���ʽ[x,y,����ϵ��sigma]
Ptarget=[Xmin,Yc-50*DY,1               %��Ŀ��λ�ã�����������5����Ŀ�꣬����һ�������Լ����ε�����
              Xmin+50*DX,Yc-50*DY,1
              Xmin+25*DX,Yc,1
              Xmin,Yc+50*DY,1
              Xmin+50*DX,Yc+50*DY,1];  
disp('Parameters:')    %������ʾ
disp('Sampling Rate in fast-time domain');disp(Fsr/Br)
disp('Sampling Number in fast-time domain');disp(Nfast)
disp('Sampling Rate in slow-time domain');disp(PRF/Ba)
disp('Sampling Number in slow-time domain');disp(Nslow)
disp('Range Resolution');disp(DY)
disp('Cross-range Resolution');disp(DX)     
disp('SAR integration length');disp(Lsar)     
disp('Position of targets');disp(Ptarget)
%%================================================================
%%���Ʒ����ź�
% figure;
% t=0:dt:4*PRT;
% duty=Tr/PRT*100;
% rect=0.5*square(2*pi*PRF*t,duty)+0.5;
% sigal_tiaozhi=cos(2*pi*Fc*t+pi*Kr*t.*t);
% sigal_fashe=rect .* sigal_tiaozhi;
% subplot(2,2,1);
% plot(t,rect);
% ylim([-1.1,1.1]);
% title('���β�');
% 
% subplot(2,2,2);
% plot(t,sigal_tiaozhi);
% ylim([-1.1,1.1]);
% title('���Ʋ���');
% subplot(2,2,3);
% plot(t,sigal_fashe);
% ylim([-1.2,1.2]);
% xlim([0,2*Tr]);
% title('�����ź�');
%%================================================================
%%���ɻز��ź�
K=Ntarget;                                %Ŀ����Ŀ
N=Nslow;                                  %��ʱ��Ĳ�����
M=Nfast;                                  %��ʱ��Ĳ�����
T=Ptarget;                                %Ŀ�����
Srnm=zeros(N,M);                          %���������洢�ز��ź�
for k=1:1:K                               %�ܹ�K��Ŀ��
    sigma=T(k,3);                         %�õ�Ŀ��ķ���ϵ��
    Dslow=sn*V-T(k,1);                    %��λ����룬ͶӰ����λ��ľ���  
    R=sqrt(Dslow.^2+T(k,2)^2+H^2);        %ʵ�ʾ������
    tau=2*R/C;                            %�ز�����ڷ��䲨����ʱ
    Dfast=ones(N,1)*tm-tau'*ones(1,M);    %(t-tau)����ʵ����ʱ�����ones(N,1)��ones(1,M)����Ϊ�˽�����չΪ����
    phase=pi*Kr*Dfast.^2-(4*pi/lambda)*(R'*ones(1,M));%��λ����ʽ�μ�P.96
    Srnm=Srnm+sigma*exp(1i*phase).*(0<Dfast&Dfast<Tr).*((abs(Dslow)<Lsar/2)'*ones(1,M));%�����Ƕ��Ŀ�귴��Ļز������Դ˴����е���
    
    %%================================================================
%���ƻز��ź�
figure;
xx=linspace(-1,1,M);
yy=linspace(-1,1,N);
[x,y]=meshgrid(xx,yy);
subplot(221);
surf(x,y,Dfast);
title('ʱ�����');
subplot(222);
surf(x,y,phase);
title('��λ');
subplot(223);
surf(x,y,abs(Srnm));
title('�ز�');
end

%%================================================================
%%���Ƴ�����
figure;
plot(Ptarget(:,2),Ptarget(:,1), 'o');
ylim([Xmin-Lsar/2,Xmax+Lsar/2]);
xlim([0,Yc+Y0]);
grid on;
ylabel('x��(��λ��)'); 
xlabel('y��(������)');
title('�۲ⳡ������Ŀ��');

%%================================================================
%%����-�������㷨��ʼ
%%������ѹ��
tic;
tr=tm-2*Rmin/C;  %ʱ����뵽0
Refr=exp(1i*pi*Kr*tr.^2).*(0<tr&tr<Tr);
Sr=ifty(fty(Srnm).*(ones(N,1)*conj(fty(Refr)))); %Ƶ����������ѹ��
Gr=abs(Sr);

% figure;
% [x,y]=meshgrid(1:size(Gr,2),1:size(Gr,1));
% surf(x,y,Gr,gradient(Gr));


%%��ʼ���о�����������������û�о����߶��� ��Ҫ����Ϊб��ı仯����ز�������㶯 
%%������������������ֵ��������Ϊ���ȱ任������������򣬷ֱ�Ե������ص����������㶯�����õ������㶯�������ֱ��ʵı�ֵ��
%%�ñ�ֵ����ΪС����������������ķ�������Ϊ�����������ڸ����ص��ϼ�ȥ�㶯��
%%��λ����fft���� ����Ƶ����������������
Sa_RD = ftx(Sr);     %  ��λ��FFT ��Ϊ�����������о�������У��
%�����㶯����,������������ ��fdc=0,ֻ��Ҫ���о�������������
Kp=1;                                  %�������Ԥ��Ԥ�˲���
h = waitbar(0,'��������ֵ');
%%���ȼ������Ǩ��������
for n=1:N     %�ܹ���N����λ����
    for m=1:M %ÿ����λ��������M���������
        delta_R = (1/8)*(lambda/V)^2*(R0+(m-M/2)*C/2/Fsr)*((n-N/2)*PRF/N)^2;%����Ǩ����P.160��(R0+(m-M/2)*C/2/Fsr)��ÿ���������m��R0���£�(n-N/2)*PRF/N����ͬ��λ��Ķ�����Ƶ�ʲ�һ��
        RMC=2*delta_R*Fsr/C;    %�˴�Ϊdelta_R/DY������ͽ���˼������뵥Ԫ
%         RMC = delta_R / DY;
        delta_RMC = RMC-floor(RMC);%����ͽ������С������
        if m+round(RMC)>M              %�ж��Ƿ񳬳��߽�
            Sa_RD(n,m)=Sa_RD(n,M/2);   
        else
            if delta_RMC>=0.5  %����
                Sa_RD(n,m)=Sa_RD(n,m+floor(RMC)+1);
            else               %����
                Sa_RD(n,m)=Sa_RD(n,m+floor(RMC));
            end
        end
    end
    waitbar(n/N)
end
close(h)
%========================
Sr_rmc=iftx(Sa_RD);   %%�����㶯У����ԭ��ʱ��
Ga = abs(Sr_rmc);
%%��λ��ѹ��
ta=sn-Xmin/V;
Refa=exp(1i*pi*Ka*ta.^2).*(abs(ta)<Tsar/2);
Sa=iftx(ftx(Sr_rmc).*(conj(ftx(Refa)).'*ones(1,M)));
Gar=abs(Sa);

% figure;
% [x,y]=meshgrid(1:size(Gar,2),1:size(Gar,1));
% surf(x,y,Gar,gradient(Gar));

toc;
%%================================================================
%%��ͼ
colormap(gray);
figure;
subplot(211);
% row=tm*C/2;%-2008;
% col=sn*V;%-26;
row = Yc + (tm * C / 2 - R0) / sin(seita);
col = sn * V;
imagesc(row,col,255-Gr);           %������ѹ����δУ�������㶯��ͼ��
% axis([Yc-Y0,Yc+Y0,Xmin-Lsar/2,Xmax+Lsar/2]);
xlabel('������'),ylabel('��λ��'),
title('������ѹ����δУ�������㶯��ͼ��'),
subplot(212);
imagesc(row,col,255-Ga);          %������ѹ����У�������㶯���ͼ��
% axis([Yc-Y0,Yc+Y0,Xmin-Lsar/2,Xmax+Lsar/2]);
xlabel('������'),ylabel('��λ��'),
title('������ѹ����У�������㶯���ͼ��'),
figure;
colormap(gray);
imagesc(row,col,255-Gar);          %��λ��ѹ�����ͼ��
% axis([Yc-Y0,Yc+Y0,Xmin-Lsar/2,Xmax+Lsar/2]);
xlabel('������'),ylabel('��λ��'),
title('��λ��ѹ�����ͼ��'),
