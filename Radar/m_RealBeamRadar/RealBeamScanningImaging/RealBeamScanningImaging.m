%������׼��ǰ�ӳ���
% author������
% time��2016-12-7
clc;
clear all;
close all;

%%  �»ز����� ��������Ŀ��ز�
disp('�»ز����� ������Ŀ��ز�');
%��������
A=4*pi/180;          %��λ������ȣ�����
L=0.0176348499;        %����
Tp=10e-6;              %����
B=80e6;                %����
fs=120e6;              %������
PRF=500;               %��Ƶ
PRT=1/PRF;             %�����ظ�����
v=65;                  %�ɻ��ٶ�
c=299792458;           %����
C = 299792458;     
aziangle =-20:0.1:20;% ��80��CPI��һ��CPIһ��Prt
theta = aziangle/180*pi;
CpiNum = length(theta);% CPI ����

d = 0.009/3;%ͨ��1��2�ļ��,��Ԫ���Ϊ0.5������
R = 7000;%Ŀ��㵽ͨ��1��2�ļ�࣬��Ŀ����ͨ��1��2�м�
% R1 = 6000;
Rn =7185; %sqrt(R^2+(50*d)^2);%Ŀ��1б��
Rn2 = 7080;%R/(cos(8/180*pi));%Ŀ��2б��
Rn3 =7080 ;%R/(cos(8/180*pi));%Ŀ��3б��
Rn4 = 7280;%R1/(cos(11/180*pi));%Ŀ��4б��
Rn5 = 7280;%R1/(cos(11/180*pi));%Ŀ��5б��
fc=c/L;%��Ƶ
Kr=B/Tp;  %��Ƶϵ��
Rmin = 6621;
tmin=2*6621/c-Tp/2;
tmax=2*7680/c+Tp/2;
dt=1/fs;
tr=tmin:dt:tmax;
Nt=length(tr);

Sr1=zeros(CpiNum,Nt);
Sr2=zeros(CpiNum,Nt);

%% ���췽��ͼ
% ����ͼ����
thetaB =atan(50*d/(2*Rn));%�������ָ���
theta1 =1/180*pi;%�������ָ���
theta2 =-1/180*pi;%�������ָ���
theta3 =-5/180*pi;%�������ָ���
F11= zeros(100,CpiNum);
F22= zeros(100,CpiNum);
F11n2= zeros(100,CpiNum);
F22n2= zeros(100,CpiNum);
F11n3= zeros(100,CpiNum);
F22n3= zeros(100,CpiNum);
% ��ÿ��ͨ��100����Ԫ
for k =1:100
F11(k,:) = exp(1j*k*(2*pi/L)*d*(sin(theta)-sin(thetaB)));%ͨ��1�ķ���ͼ
end
F1 = sum(F11);

for k=1:100
F22 (k,:)= exp(1j*k*(2*pi/L)*d*(sin(theta)-sin(-thetaB)));%ͨ��2�ķ���ͼ
end 
F2 = sum(F22);
FSum = (F1)+(F2);%��ͨ������ͼ
FSumabs = abs(F1)+abs(F2);%��ͨ������ͼ
% ��ÿ��ͨ��100����Ԫ
for k =1:100
F11n2(k,:) = exp(1j*k*(2*pi/L)*d*(sin(theta+theta1)-sin(thetaB)));%ͨ��1�ķ���ͼ
end
F1n2 = sum(F11n2);

for k=1:100
F22n2 (k,:)= exp(1j*k*(2*pi/L)*d*(sin(theta+theta1)-sin(thetaB)));%ͨ��2�ķ���ͼ
end 
F2n2 = sum(F22n2);
FSumn2 = abs(F1n2)+abs(F2n2);%��ͨ������ͼ


% ��ÿ��ͨ��100����Ԫ
for k =1:100
F11n3(k,:) = exp(1j*k*(2*pi/L)*d*(sin(theta+theta2)-sin(thetaB)));%ͨ��1�ķ���ͼ
end
F1n3 = sum(F11n3);

for k=1:100
F22n3 (k,:)= exp(1j*k*(2*pi/L)*d*(sin(theta+theta2)-sin(thetaB)));%ͨ��2�ķ���ͼ
end 
F2n3 = sum(F22n3);
FSumn3 = abs(F1n3)+abs(F2n3);%��ͨ������ͼ

% ��ÿ��ͨ��100����Ԫ
F11n4= zeros(100,CpiNum);
F22n4= zeros(100,CpiNum);
for k =1:100
F11n4(k,:) = exp(1j*k*(2*pi/L)*d*(sin(theta+theta3)-sin(thetaB)));%ͨ��1�ķ���ͼ
end
F1n4 = sum(F11n4);

for k=1:100
F22n4(k,:)= exp(1j*k*(2*pi/L)*d*(sin(theta+theta3)-sin(thetaB)));%ͨ��2�ķ���ͼ
end 
F2n4 = sum(F22n4);
FSumn4 = abs(F1n4)+abs(F2n4);%��ͨ������ͼ

F1db = 20*log10(abs(F1)./max(abs(F1)));
F2db = 20*log10(abs(F2)./max(abs(F2)));
FSumdb = 20*log10(abs(FSum)./max(abs(FSum)));

figure(1);
subplot(2,1,1);
plot(aziangle,F1db);
xlabel('��λ�ǣ��㣩');
ylabel('��һ����dB��')
title('ͨ��1���߷���ͼ��һ��ͼ');

subplot(2,1,2);
plot(aziangle,F2db);
xlabel('��λ�ǣ��㣩');
ylabel('��һ����dB��')
title('ͨ��2���߷���ͼ��һ��ͼ');

figure(2);
plot(aziangle,FSumdb);
xlabel('��λ�ǣ��㣩');
ylabel('��һ����dB��')
legend('��ͨ����һ������ͼ');
%% �����ͨ��������
yy = exp(-1i*4*pi*Rn/L+1i*pi*Kr*(tr-2*Rn/c).^2).*(abs(tr-2*Rn/c)<Tp/2);
for i=1:CpiNum
    for j=1:2
        Sr1(i,:)=FSumabs(i).*(exp(-1i*4*pi*Rn/L+1i*pi*Kr*(tr-2*Rn/c).^2).*(abs(tr-2*Rn/c)<Tp/2))+...
            FSumn2(i).*(exp(-1i*4*pi*Rn2/L+1i*pi*Kr*(tr-2*Rn2/c).^2).*(abs(tr-2*Rn2/c)<Tp/2))+...
            FSumn4(i).*(exp(-1i*4*pi*Rn2/L+1i*pi*Kr*(tr-2*Rn2/c).^2).*(abs(tr-2*Rn2/c)<Tp/2))+...
            FSumn3(i).*(exp(-1i*4*pi*Rn3/L+1i*pi*Kr*(tr-2*Rn3/c).^2).*(abs(tr-2*Rn3/c)<Tp/2))+...
            FSumn2(i).*(exp(-1i*4*pi*Rn3/L+1i*pi*Kr*(tr-2*Rn4/c).^2).*(abs(tr-2*Rn4/c)<Tp/2))+...
            FSumn3(i).*(exp(-1i*4*pi*Rn5/L+1i*pi*Kr*(tr-2*Rn5/c).^2).*(abs(tr-2*Rn5/c)<Tp/2));
%         Sr1(i,:)=FSum(i).*(exp(-1i*4*pi*Rn/L+1i*pi*Kr*(tr-2*Rn/c).^2).*(abs(tr-2*Rn/c)<Tp/2))+...
%             FSumn2(i).*(exp(-1i*4*pi*Rn2/L+1i*pi*Kr*(tr-2*Rn2/c).^2).*(abs(tr-2*Rn2/c)<Tp/2))+...
%             FSumn3(i).*(exp(-1i*4*pi*Rn5/L+1i*pi*Kr*(tr-2*Rn5/c).^2).*(abs(tr-2*Rn5/c)<Tp/2));
%         Sr1(i,:)=FSum(i).*(exp(-1i*4*pi*Rn/L+1i*pi*Kr*(tr-2*Rn/c).^2).*(abs(tr-2*Rn/c)<Tp/2))+...
%             FSumn2(i).*(exp(-1i*4*pi*Rn2/L+1i*pi*Kr*(tr-2*Rn2/c).^2).*(abs(tr-2*Rn2/c)<Tp/2));
%         Sr1(i,:)=FSumabs(i).*(exp(-1i*4*pi*Rn/L+1i*pi*Kr*(tr-2*Rn/c).^2).*(abs(tr-2*Rn/c)<Tp/2));
    end
end
%% ���ź���Ӹ���˹����������
% for k =1:CpiNum
% Sr1(k,:) = awgn(Sr2(k,:),-11);
% end
% Sr2 = wgn(CpiNum,Nt,0);
% Sr1 = Sr1+Sr2;

Sr1 = awgn(Sr1,5,'measured');

% SNR = -5;
% for k = 1:CpiNum
% NOISE=randn(size(Sr2(k,:)));
% NOISE=NOISE-mean(NOISE);
% signal_power = 1/length(Sr2(k,:))*sum(Sr2(k,:).*Sr2(k,:));
% noise_variance = signal_power / ( 10^(SNR/10) );
% NOISE=sqrt(noise_variance)/std(NOISE)*NOISE;
% Sr1(k,:)=Sr2(k,:)+NOISE;
% end

%%
figure(3);
imagesc(real(Sr1));colormap gray;%�ز��ź�(ʵ��)�Ҷ�ͼ
xlabel('������/m');ylabel('��λ��/m');
title('��ͨ���ز��ź�ʵ���ĻҶ�ͼ');

% FidWrite1= fopen('E:\matlabfile\graduatefile\ʵ��������������׼�򳬷ֱ��㷨matlab\SimulateDataSum.bin','w');%���ɷ��������ļ�
FidWrite1= fopen('.\SimulateDataSum.bin','w');%���ɷ��������ļ�

SrSumData=zeros(1,2*Nt);
% �����ͨ������
for k = 1:CpiNum
SrSumData(1:2:end) = real(Sr1(k,:));
SrSumData(2:2:end) = imag(Sr1(k,:));
fwrite(FidWrite1,SrSumData,'float32')
end
fclose all;
%% �������
Na =1;
Nr =Nt;
Prf = PRF;
Fs = fs;
Br = B;
NrNew = 1024;
ku = -12;
kv = 18;
N = 1;
yaxis = tr*C/2;
xaxis =aziangle(1):(aziangle(CpiNum)-aziangle(1))/(CpiNum*N-1):aziangle(CpiNum) ;
%% ��ȡ��·����
disp('��ȡ��·����·����')
% FolderImageOutPut = 'E:\matlabfile\graduatefile\ʵ��������������׼�򳬷ֱ��㷨matlab\';
FolderImageOutPut = '.\';
FidReadSum = fopen([FolderImageOutPut 'SimulateDataSum.bin'],'r');
FidReadReal = fopen('EcholRealSum.dat','w');
FidReadImag = fopen('EcholImagSum.dat','w');

dataline = zeros(CpiNum,Nr);
for k = 1:CpiNum
   DataSum = fread(FidReadSum,Nr*2,'float32');
   dataline(k,:) = DataSum(1:2:2*Nr)+1j*DataSum(2:2:2*Nr);
   fwrite(FidReadReal,DataSum(1:2:end),'float32');
   fwrite(FidReadImag,DataSum(2:2:end),'float32');
end
fclose all;
figure(4);
imagesc(abs(dataline)),colormap gray;
title('ԭʼ���ݻҶ�ͼ');
xlabel('������');
ylabel('��λ��');
%%  ��������ѹ
disp('��������ѹ')
StepRanCompSum;

FidReadReal = fopen('RanCompRealSum.dat','r');
FidReadImag= fopen('RanCompImagSum.dat','r');


Y = zeros(NrNew,CpiNum);
for k = 1:CpiNum
    YReal = fread(FidReadReal,NrNew,'float32');
    YImag = fread(FidReadImag,NrNew,'float32');
    Y(:,k) = YReal +1j*YImag;
end
figure;
imagesc(xaxis,yaxis,abs(Y)),colormap hot;
title ('��ѹ��Ҷ�ͼ');
xlabel('��λ�� X(��)');
ylabel('������ Y(m)');



%% �γɾ��� ����ͼ����
FSum1 =(FSumabs);
Mnum =CpiNum+CpiNum-1;
Nnum = CpiNum;
F1A = zeros (Mnum,Nnum);
for k= 1:Nnum
    for j=1:Mnum
        if (j<k)||(k+CpiNum-1<j)
            F1A(j,k)=0;
        else 
            F1A(j,k)=(FSum1(j-k+1));
        end       
    end
end
%% ��������1
FSum2 = fliplr(FSum1);
m =100;%��������;
lamda = 2;
q =2;
rou = 1/lamda;
miu =150;
A =(1+rou*miu)^(-q);
XX = zeros(NrNew,CpiNum);
for k =1:NrNew
    sigma = Y(k,:);
    %% ��������
    for j =1: m  
        fenmu = ifft(fft(FSum1).*fft(sigma));%���
        %ȷ��fenmu����0
        for l =1:CpiNum
            if fenmu(l) == 0
                fenmu(l) =0.001;
            end
        end      
        fenshi1 =(Y(k,:)./fenmu);%���
        fenshi =ifft(fft((FSum2)).*fft(fenshi1))*rou-rou-log(sigma);%���
        sigma_end =sigma.*((fenshi).^q)*A;%���
        sigma = sigma_end;
    end   
    XX(k,:) = fftshift(sigma_end);
end
%%
figure;
Ynum = ceil(1.5/39.5*CpiNum);
XX0=circshift(XX,[0 -Ynum]);   
imagesc(xaxis,yaxis,abs(XX)),colormap hot;
title ('����������׼�����ȥ����㷨������');
xlabel('��λ�� X���㣩');
ylabel('������ Y��m��');
fclose all;


figure;
subplot(2,1,1);
plot(xaxis,abs(Sr1(:,370))/abs(max(Sr1(:,370))));
grid on;
xlabel('��λ�ǣ��㣩')
ylabel('��ֵ')
title('ʵ����ɨ�������ͼ');
subplot(2,1,2);
plot(xaxis,abs(XX(370,:))/abs(max(XX(370,:))),'r');
grid on;
xlabel('��λ�ǣ��㣩')
ylabel('��ֵ')
title('����������׼�����ȥ���������ͼ')
%% 
figure;
plot(xaxis,20*log10(abs(Y(454,:))/abs(max(Y(454,:)))));
xlabel('��λ�ǣ��㣩')
ylabel('��ֵ')
title('ʵ����ɨ���Ŀ��-3dB���')
figure;
plot(xaxis,20*log10(abs(XX(454,:)/abs(max(XX(454,:))))),'r');
grid on;
xlabel('��λ�ǣ��㣩')
ylabel('��ֵ')
title('����������׼�����ȥ�����-3dB���')

%% ���ɵ�.raw�ļ�

FidWriteReal = fopen('EndProcessDataReal.dat','w');
FidWriteImag = fopen('EndProcessDataImag.dat','w');
for k = 1:NrNew
DataReal = real(XX(k,:));
DataImag = imag(XX(k,:));
fwrite(FidWriteReal,DataReal,'float32');
fwrite(FidWriteImag,DataImag,'float32');
end

ResultDisplayRaw('EndProcessDataReal.dat','EndProcessDataImag.dat',[FolderImageOutPut '������׼��.raw'],NrNew,CpiNum);



%% ����y�����СΪNrNew������Ҫ���в�ֵ��CpiNum+CpiNum-1��С
% 
% X0 =18.5:0.25:58;
X0 = linspace(18.5,58,401);
YY = zeros(Mnum,NrNew);
X01 = 18.5:(39.5/(Mnum-1)):58;
for k =1:NrNew
    YY(:,k) = interp1(X0,Y(k,:),X01,'linear');
end

%%  ��������2
m =3;%��������;
q = 3;
XX = zeros(NrNew,CpiNum);
for k =1:NrNew
    k
    sigma = Y(k,:)';
    %% ��������
    for j =1: m  
        fenmu = F1A*sigma;
        fenshi1 =(YY(:,k)./fenmu);
        fenshi =(F1A')*fenshi1;
        sigma_end =sigma.*((fenshi).^q);
        sigma = sigma_end;
    end   
    XX(k,:) = (sigma_end);
end


%%
figure;
imagesc(xaxis,yaxis,abs(XX)),colormap gray;

title ('ʵ�������������Ȼ׼�򳬷ֱ��㷨�������ݷ���ͼ');
xlabel('��λ�� X(��)');
ylabel('������ Y(m)');
fclose all;

% 
