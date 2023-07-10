%%================================================================
%%�ļ�����SincSAR.m
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
R0=sqrt(Yc^2+H^2);               %��̾���
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
sn=linspace((Xmin-Lsar/2)/V,(Xmax+Lsar/2)/V,Nslow);%��ʱ�����ʱ����� �ο�ʱ��Ϊ���������
PRT=(Xmax-Xmin+Lsar)/V/Nslow;    %����Nslow�ı��ˣ�������Ӧ��һЩ����Ҳ��Ҫ���£����ڼ�С��
PRF=1/PRT;
ds=PRT;
%%��ʱ�����������
Tr=5e-6;                         %�������ʱ��5us
Br=30e6;                        %chirpƵ�ʵ��ƴ���Ϊ30MHz
Kr=Br/Tr;                        %chirp��Ƶ��
Fsr=2*Br; 
% Fsr=Br;                        %��ʱ�����Ƶ�ʣ�Ϊ3���Ĵ���
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
end
%%================================================================
%%����-�������㷨��ʼ
%%������ѹ��
tic;
tr=tm-2*Rmin/C;
Refr=exp(1i*pi*Kr*tr.^2).*(0<tr&tr<Tr); %����ƥ�亯��
Sr=ifty(fty(Srnm).*(ones(N,1)*conj(fty(Refr))));
Gr=abs(Sr);

%����ѹ������
% figure;
% plot(abs(Sr(N/2,:)),'r');
% hold on;
% plot(abs(Sr(N,:)),'b');
%%��ʼ���о�����������������û�о����߶��� ��Ҫ����Ϊб��ı仯����ز�������㶯 
%%������������������ֵ��������Ϊ���ȱ任������������򣬷ֱ�Ե������ص����������㶯�����õ������㶯�������ֱ��ʵı�ֵ��
%%�ñ�ֵ����ΪС����������������ķ�������Ϊ�����������ڸ����ص��ϼ�ȥ�㶯��
%%��λ����fft���� ����Ƶ����������������
Sa_RD = ftx(Sr);     %  ��λ��FFT ��Ϊ�����������о�������У��
%�����㶯����,������������ ��fdc=0,ֻ��Ҫ���о�������������
Kp=1;                                  %�������Ԥ��Ԥ�˲���
%%�ڶ��ַ������нض�sinc��ֵ���о���ͽ��У��
h = waitbar(0,'Sinc��ֵ');
P=4;%4��sinc��ֵ
RMCmaxtix = zeros(N,M);
for n=1:N
    for m=P:M
       delta_R = (1/8)*(lambda/V)^2*(R0+(m-M/2)*C/2/Fsr)*((n-N/2)*PRF/N)^2;%���ȼ������Ǩ���� ���㷽�����ǰ�б��任��������������֪����
%        RMC=2*delta_R*Fsr/C;         %����ͽ���˼������뵥Ԫ
        RMC = delta_R / DY;
       delta_RMC = RMC-floor(RMC);  %����ͽ������С������
       for i = -P/2:P/2-1
           if m+RMC+i>M              %�ж��Ƿ񳬳��߽�
                RMCmaxtix(n,m)=RMCmaxtix(n,m)+Sa_RD(n,M)*sinc((i+RMC));
           else
                RMCmaxtix(n,m)=RMCmaxtix(n,m)+Sa_RD(n,m+floor(RMC)+i)*sinc(i+delta_RMC);
           end
       end
    end
    waitbar(n/N)
end
close(h)
%========================
Sr_rmc=iftx(RMCmaxtix);   %%�����㶯У����ԭ��ʱ��
Ga = abs(Sr_rmc);
%%��λ��ѹ��
ta=sn-Xmin/V;
Refa=exp(1i*pi*Ka*ta.^2).*(abs(ta)<Tsar/2);
Sa=iftx(ftx(Sr_rmc).*(conj(ftx(Refa)).'*ones(1,M)));
Gar=abs(Sa);
toc;
%%================================================================
%%��ͼ
colormap(gray);
figure(1)
subplot(211);
row=tm*C/2-2008;col=sn*V-26;
imagesc(row,col,255-Gr);           %������ѹ����δУ�������㶯��ͼ��
axis([Yc-Y0,Yc+Y0,Xmin-Lsar/2,Xmax+Lsar/2]);
xlabel('������'),ylabel('��λ��'),
title('������ѹ����δУ�������㶯��ͼ��'),
subplot(212);
imagesc(row,col,255-Ga);          %������ѹ����У�������㶯���ͼ��
axis([Yc-Y0,Yc+Y0,Xmin-Lsar/2,Xmax+Lsar/2]);
xlabel('������'),ylabel('��λ��'),
title('������ѹ����У�������㶯���ͼ��'),
figure(2)
colormap(gray);
imagesc(row,col,255-Gar);          %��λ��ѹ�����ͼ��
axis([Yc-Y0,Yc+Y0,Xmin-Lsar/2,Xmax+Lsar/2]);
xlabel('������'),ylabel('��λ��'),
title('��λ��ѹ�����ͼ��'),
