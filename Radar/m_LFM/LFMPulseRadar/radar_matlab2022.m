%==============================================================================%
%% �ó������16����Ƶ�����źŵĲ���������ѹ����MTI��MTD��CFAR���źŴ����㷨
%% �����������״ﰮ����ѧϰ���������Լ�̽������
%% ʱ��2022��04��
%% ==============================================================================%
close all; %�ر�����ͼ��
clear all; %������б���
clc;
%% �״��������
% ===================================================================================%
C=3.0e8;          %���� (m/s)
RF=3.140e9/2;     %�״���Ƶ
Lambda=C/RF;      %�״﹤������
PulseNumber=16;   %�ز�������
BandWidth=2.0e6;  %�����źŴ���2G  
TimeWidth=42.0e-6;%�����ź�ʱ��42us
PRT=240e-6;       %�״﷢�������ظ�����(s)=240us����Ӧ1/2*240*300=36000��
PRF=1/PRT;
Fs=2.0e6;            %����Ƶ��2M
NoisePower=-12;%(dB);%�������ʣ�Ŀ��Ϊ0dB��
% ---------------------------------------------------------------%
SampleNumber=fix(Fs*PRT);            %����һ���������ڵĲ�������480��
TotalNumber=SampleNumber*PulseNumber;%�ܵĲ�������480*16=TotalNumber��
BlindNumber=fix(Fs*TimeWidth);       %����һ���������ڵ�ä��-�ڵ�������=84��

%===================================================================================%
%% Ŀ���������                                       
%===================================================================================%
X=9;Y=2;Z=0;                                                           %�����������ɿ���Ŀ��ľ�����ٶ�

TargetNumber=4;                                                        %Ŀ�����

SigPower(1:TargetNumber)=[1 1 0.25 1];                                 %Ŀ�깦��,������

TargetDistance(1:TargetNumber)=[2800 8025 8025 9000+(Y*10+Z)*200];     %Ŀ�����,��λm 9200��Ҫ��9000+(Y*10+Z)*200

DelayNumber(1:TargetNumber)=fix(Fs*2*TargetDistance(1:TargetNumber)/C);% ��Ŀ����뻻��ɲ����㣨�����ţ�

TargetVelocity(1:TargetNumber)=[50 -100 0 (200+X*10+Y*10+Z)];          %Ŀ�꾶���ٶ� ��λm/s   230��Ҫ��Ϊ(200+X*10+Y*10+Z)

TargetFd(1:TargetNumber)=2*TargetVelocity(1:TargetNumber)/Lambda;      %����Ŀ��ಷ��

%====================================================================================%
%% �������Ե�Ƶ�ź�                                  
%====================================================================================%
number=fix(Fs*TimeWidth);%�ز��Ĳ�������=��ѹϵ������=��̬����Ŀ+1=83+1
if rem(number,2)~=0
    number=number+1;
end                                                                                                                                                                   

for i=-fix(number/2):fix(number/2)-1
    Chirp(i+fix(number/2)+1)= exp(j*(pi*(BandWidth/TimeWidth)*(i/Fs)^2));%exp(j*pi*ut^2)��uΪ����б��
    freq(i+fix(number/2)+1) = (BandWidth/TimeWidth)*(i/Fs);%f=ut
end   
coeff=conj(fliplr(Chirp));%������ѹϵ�����ԳƷ�ת�������h(t)=s*(-t)

%% ���Ե�Ƶ�ź�ͼʾ
figure(1);
subplot(2,1,1);
plot(real(Chirp),'r-');title('���Ե�Ƶ�źŵ�ʵ��(��ɫ)���鲿����ɫ��');
hold on;
plot(imag(Chirp),'b-');
hold off;
subplot(2,1,2);plot(freq);title('Ƶ�ʱ仯����');
%========================================================

%% ����Ŀ��ز��� 
SignalAll=zeros(1,TotalNumber);%����������ź�,����0
for k=1:TargetNumber% ���β�������Ŀ��1 2 3 4
    SignalTemp=zeros(1,SampleNumber);% һ������
    SignalTemp(DelayNumber(k):DelayNumber(k)+number-1)=sqrt(SigPower(k))*Chirp;%һ�������1��Ŀ�꣨δ�Ӷ������ٶȣ�
    Signal=zeros(1,TotalNumber);
    for i=1:PulseNumber
        Signal((i-1)*SampleNumber+1:i*SampleNumber)=SignalTemp;
    end
    FreqMove=exp(j*2*pi*TargetFd(k)*(0:TotalNumber-1)/Fs);%Ŀ��Ķ������ٶ�*ʱ��=Ŀ��Ķ���������
    Signal=Signal.*FreqMove;
    SignalAll=SignalAll+Signal;
end
%�ز��ź�ͼʾ  7680�㣨δ����ä����
figure(2);
subplot(2,1,1);plot(real(SignalAll),'r-');title('ģ��Ŀ���źŵ�ʵ��');
subplot(2,1,2);plot(imag(SignalAll));title('ģ��Ŀ���źŵ��鲿');

%====================================================================================%
%% ����ϵͳ�����ź�                               
%====================================================================================%
SystemNoise=normrnd(0,10^(NoisePower/10),1,TotalNumber)+j*normrnd(0,10^(NoisePower/10),1,TotalNumber);
%====================================================================================%

%% �ܵĻز��ź�                                    
%====================================================================================%
Echo=SignalAll+SystemNoise;% +SeaClutter+TerraClutter;
figure;
subplot(2,1,1);plot(real(Echo(1:SampleNumber)));title('��һ��PRT�ز��źŵ�ʵ��,�����ڲ�Ϊ0');hold on;
for i=1:PulseNumber   %�ڽ��ջ�������,���յĻز�Ϊ0
    Echo((i-1)*SampleNumber+1:(i-1)*SampleNumber+number)=0;
end
subplot(2,1,2);plot(real(Echo(1:SampleNumber)));title('��һ��PRT�ز��źŵ�ʵ��,������Ϊ0');hold off;
%%�ز��ź�ͼʾ  7680�㣨��ä����
figure;
subplot(2,1,1);plot(real(Echo));title('�ܻز��źŵ�ʵ��,������Ϊ0');
subplot(2,1,2);plot(imag(Echo));title('�ܻز��źŵ��鲿,������Ϊ0');


%% ================================ʱ����ѹ=================================%%
pc_time0 = conv(Echo,coeff);
pc_time1 = pc_time0(number:TotalNumber+number-1);%ȥ����̬�� number-1��
% pc_time2 = pc_time0(number/2:TotalNumber+number/2-1);
% pc_time3 = pc_time0(1:TotalNumber-1);
figure();
subplot(2,1,1);plot(real(SignalAll(1:SampleNumber)));title('�ز��ź�');
subplot(2,1,2);plot(abs(pc_time0(1:SampleNumber)));title('ʱ����ѹ���������̬�㣩');

figure();
subplot(2,1,1);plot(real(SignalAll(1:SampleNumber)));title('�ز��ź�');
subplot(2,1,2);plot(abs(pc_time1(1:SampleNumber)));title('ʱ����ѹ�����ȥ����̬�㣩');

% figure();
% subplot(2,1,1);plot(real(SignalAll(1:SampleNumber)));title('�ز��ź�');
% subplot(2,1,2);plot(abs(pc_time2(1:SampleNumber)));title('ʱ����ѹ�����ǰ���ȥһ�룩');
% 
% figure();
% subplot(2,1,1);plot(real(SignalAll(1:SampleNumber)));title('�ز��ź�');
% subplot(2,1,2);plot(abs(pc_time3(1:SampleNumber)));title('ʱ����ѹ�����ȥ������̬�㣩');

%% ================================Ƶ����ѹ=================================%%
Echo_fft=fft(Echo,8192);%��Ӧ����TotalNumber+number-1��FFT,��Ϊ����������ٶ�,������8192���FFT
coeff_fft=fft(coeff,8192);
%%Ϊ�����coeff
coefffft(1,:)=real(coeff_fft);
coefffft(2,:)=imag(coeff_fft);

pc_fft=Echo_fft.*coeff_fft;
pc_freq0=ifft(pc_fft);
pc_freq1 = pc_freq0(number:TotalNumber+number-1);
figure();
subplot(2,1,1);plot(abs(pc_freq0(1:8192)));title('Ƶ����ѹ���,����̬��');
subplot(2,1,2);plot(abs(pc_freq1(1:TotalNumber)));title('Ƶ����ѹ���,ȥ����̬��');

figure();
subplot(2,1,1);plot(abs(pc_time1(1:480)));title('��һ��PRT��ʱ����ѹ���');
subplot(2,1,2);plot(abs(pc_freq1(1:480)));title('��һ��PRT��Ƶ����ѹ���');

%% ΪDSP�����ṩ�ز����ݡ���ѹϵ�����ⲿ�ִ���ɾ������Ҫ��
%  fo=fopen('echo.dat','wb');
%  for i=1:TotalNumber
%      fprintf(fo,'%f,\n',real(Echo(i)));
%      fprintf(fo,'%f,\n',imag(Echo(i)));
%  end
%  for i=TotalNumber+1:8192
%      fprintf(fo,'%f,\n',0);
%      fprintf(fo,'%f,\n',0);
%  end
% fclose(fo);
% fo=fopen('coeff_fft.dat','wb');%Ƶ����ѹϵ��
% for i=1:8192
%     fprintf(fo,'%f,\n',real(coeff_fft(i)));
%     fprintf(fo,'%f,\n',imag(coeff_fft(i)));
% end
% fclose(fo);
% 
% %% ������ѹ���
% pc_freq12 = abs(pc_freq1);
% fo=fopen('pc_freq_abs_m.dat','wb');
% for i=1:7680
%     fprintf(fo,'%f,\n',pc_freq12(i));
% end
% fclose(fo);

%% ================��������š������ź���������=================================%%
for i=1:PulseNumber
    pc(i,1:SampleNumber)=pc_freq1((i-1)*SampleNumber+1:i*SampleNumber);
end

%% ================MTI����Ŀ����ʾ��,һ�ζ�����ֹZĿ��͵���Ŀ��---�������Ӳ�=================================%

%% MTI ��Ŀ����ʾ
f=-PRF:PRF;
H=4*(sin(pi*f/PRF)).^2;
figure();
plot(f,(sqrt(H)), 'b');
% hold on;
% plot(f, (H), 'r');
title('MTI�˲���');
xlabel('Ƶ��f');
ylabel('����|H(f)|');

for i=1:PulseNumber-1               %��������������һ������
    mti(i,:)=pc(i+1,:)-pc(i,:);
end

figure();
mesh(abs(mti));title('MTI ���');
figure();
plot(abs(mti(1,:)));title('MTI �������һ�ζ�����');

%% ����MTI���
% mti12 = abs(mti);
% fo=fopen('mti_abs_m.dat','wb');
% for i=1:7200
%     fprintf(fo,'%f,\n',mti12(i));
% end
% fclose(fo);

%% ================MTD����Ŀ���⣩,���ֲ�ͬ�ٶȵ�Ŀ�꣬�в�������=================================%
mtd=zeros(PulseNumber,SampleNumber);
for i=1:SampleNumber
    buff(1:PulseNumber)=pc(1:PulseNumber,i);
    buff_fft=fftshift(fft(buff)); %��fftshift����Ƶ���Ƶ��м� �������Է���۲��ٶ�����
    mtd(1:PulseNumber,i)=buff_fft(1:PulseNumber)';
end
x=1:1:SampleNumber;
y=-8:1:7;%ͨ��������������ͨ�����˵�λֵ�����ٶ�ֵ��
figure();mesh(x,y,abs(mtd));title('MTD���');xlabel('���뵥Ԫ');ylabel('������ͨ��');zlabel('����ֵ');

% %% ����MTD���
% mtd12 = abs(mtd);
% fo=fopen('mtd_abs_m.dat','wb');
% for i=1:7680
%     fprintf(fo,'%f,\n',mtd12(i));
% end
% fclose(fo);
% 


%% MTD ��Ŀ����
N=16;
for m=1:N
     ww(m,:)=exp(-j*2*pi*m*(0:N-1)/N);
end
Hd=fftshift(fft(ww,480)); %% FFTխ���˲�����
y=1:0.1:16;
figure;
plot(linspace(0, PRF,480),abs(Hd));title('�������˲������Ƶ����Ӧ');xlabel('Ƶ��f');ylabel('������Ӧ|H(f)|');
figure;
plot(linspace(0,PRF,480),abs(Hd(:,9)));title('�����������˲�����Ƶ����Ӧ');xlabel('Ƶ��f');ylabel('������Ӧ|H(f)|');
Hd_re = [Hd' Hd']';
figure;
plot(linspace(-PRF,PRF,960),abs(Hd_re));title('�������˲������Ƶ����Ӧ');xlabel('Ƶ��f');ylabel('������Ӧ|H(f)|');
hold on;
plot([523,523], [0,16], '-.k');
hold on;
plot([0,0], [0,16], '-.k');
hold on;
plot([-1047,-1047], [0,16], '-.k');
hold on;
plot([2868,2868], [0,16], '-.k');

%% CFAR��ⲿ�֣�GO-CFAR�� =================================% 
cfar=zeros(PulseNumber,SampleNumber);
T=4;
for i=1:PulseNumber
    for k=1:2
        left=0;
        mtd_abs = abs(mtd);
        right=mean(mtd_abs(i,k+2:k+17));    %%%%��2�Ǽ���һ��������Ԫ��ѡȡ16���ο���Ԫ��ƽ��
        maxV=max(left,right);
        if(mtd_abs(i,k)>=T*maxV)
            cfar(i,k)=mtd_abs(i,k);
        else
            cfar(i,k)=0;
        end
    end
    for k=3:17
        left=mean(mtd_abs(i,1:k-2));
        right=mean(mtd_abs(i,k+2:k+17));
        maxV=max(left,right);
        if(mtd_abs(i,k)>=T*maxV)
            cfar(i,k)=mtd_abs(i,k);
        else
            cfar(i,k)=0;
        end
    end
    for k=18:SampleNumber-18
        left=mean(mtd_abs(i,k-17:k-2));
        right=mean(mtd_abs(i,k+2:k+17));
        maxV=max(left,right);
        if(mtd_abs(i,k)>=T*maxV)
            cfar(i,k)=mtd_abs(i,k);
        else
            cfar(i,k)=0;
        end
    end
    for k=SampleNumber-17:SampleNumber-2
        left=mean(mtd_abs(i,k-17:k-2));
        right=mean(mtd_abs(i,k+2:SampleNumber));
        maxV=max(left,right);
        if(mtd_abs(i,k)>=T*maxV)
            cfar(i,k)=mtd_abs(i,k);
        else
            cfar(i,k)=0;
        end
    end
    for k=SampleNumber-1:SampleNumber
        left=mean(mtd_abs(i,k-17:k-2));
        right=0;
        maxV=max(left,right);
        if(mtd_abs(i,k)>=T*maxV)
            cfar(i,k)=mtd_abs(i,k);
        else
            cfar(i,k)=0;
        end
    end
end
x=1:1:480;
y=-8:1:7;
figure;mesh(x,y,cfar);title(' CFAR MATLAB result��������ֵ T=4��');
xlabel('���뵥Ԫ');
ylabel('������ͨ��');
zlabel('����ֵ');

%% ����CFAR�����ɾ����
% fo=fopen('cfar_result_m.dat','wb');
% for i=1:7680
%     fprintf(fo,'%f,\n',cfar(i));
% end
% fclose(fo);

