
%%���ߣ�
% -----------------------------��һ��------------------------------------%
clear all;close all;clc;
%% ==========================ʵ�����===============================%
C=3e8;                       %����
ae= 8494;                    %������Ч�뾶
lambda=0.03;                 %����
taup=160e-6;                 %������
BW=1e6;                      %��Ƶ����
mu=BW/taup;                  %��Ƶϵ��
D=0.25;                      %���߿׾�
Ae=0.25*pi*D^2;              %������Ч���
G=4*pi*Ae/lambda^2;          %��������
RCS=1500;                    %Ŀ��RCS���״�������
k=1.38e-23;                  %������������
T=290;                       %��׼�����¶ȣ������ģ�
F=3;                         %����ϵ��(dB)
L=4;                         %ϵͳ���(dB)
Lp=5;                        %�źŴ�����ʧ(dB)
N_CI=64;                     %������������
Pt_CI=30;                    %64������ɻ���ʱ���书��
Pt =1;                       %����ķ�ֵ����
Ru=80000;                    %��ģ��̽�����
theta_3dB=6;                 %���߲������(�Ƕ�)
PRT=800e-6;                  %����״̬�����ظ�����
Fs=2e6;                      %����Ƶ��
Va=600;                      %�����ٶ� m/s
Vs=5;                        %Ŀ�꺽�ٸ���ѧ������Ϊ 5m/s
alpha=30;                    %Ŀ�꺽���뵯�᷽��н�(�Ƕ�)
beta=1;                      %Ŀ��ƫ�뵯�᷽��н�(�Ƕ�)
Rs=40000;                    %�������� Ŀ��������ѧ�ż���Ϊ40km
nTr=fix(PRT*Fs);             %ÿ�������ظ����ڲ����� 1600
nTe=fix(taup*Fs);            %ƥ���˲�����   320
nTe=nTe+mod(nTe,2);          %ƥ���˲�����ȡż��
P_fa=10e-6;                  %�龯����
phi0  = 10;                  %��������10��
Gt_dB = 0;                   %��������
Gr_dB = 0;                   %��������
B =10;                       %����MHz
D0=12.5;                     %�������

%% =========================1.1 ģ������================================%%
%% ģ������ͼ
eps=1e-10;                                           %��ֹ��������
tau=-taup:taup/1600:taup-taup/1600;                  %tau��ĵ���
fd=-BW:BW/1000:BW-BW/1000;                         
[X,Y]=meshgrid(tau,fd);
temp1=1-abs(X)./taup;
temp2=pi*taup*(mu*X+Y).*temp1+eps;
lfm=abs(temp1.*sin(temp2)./temp2);                   %ģ������ģֵ
figure(1);mesh(tau*1e6,fd*1e-6,lfm);                 %ģ������ͼ
xlabel('ʱ��/us');ylabel('�����գ�fd)/MHz');title('|X(\tau,fd)|ģ������ͼ');grid on;
%% ��������ģ������ͼ
[m1,m2]=find(lfm==max(max(lfm)));                    %�ҵ�ԭ��
figure(2);plot(tau,20*log10(lfm(m1,:)),'b');         %��������ģ������ͼ
axis([-160e-6 160e-6 -60 0]);
xlabel('\tau/us');ylabel('|X(\tau,0)|(dB)');title('|X(\tau,0)|����ģ��ͼ');grid on;
%% �����ٶ�ģ������ͼ
figure(3);
plot(fd,20*log10(lfm(:,m2)),'b');                 %�����ٶ�ģ������ͼ
axis([-1e6 1e6 -60 0]);
xlabel ('������/Hz');ylabel ('ģ������/dB');title('������ģ��ͼ');

%% %����-4dB�ȸ���ͼ
figure(4);contour(tau*1e6,fd*1e-6,lfm,[10^(-4/20),10^(-4/20)],'g');
xlabel('\tau/us');ylabel('fd/MHz');title('ģ��������-4dB�и�ȸ���ͼ');
%% -4dB�ȸ���ͼ�ֲ��Ŵ�ͼ
figure();
contour(tau*1e6,fd*1e-6,lfm,[10^(-4/20),10^(-4/20)],'g'); 
axis([-7,4,-0.02 ,0.05]);
xlabel('\tau/us');ylabel('fd/MHz');title('ģ��������-4dB�и�ȸ���ͼ(�ֲ��Ŵ�)');
%% %����-3dBʱ�����
[I2,J2]=find(abs(20*log10(lfm)-(-3)) < 0.1)  ;
tau_3db=abs(tau(J2(end))-tau(J2(1)))*1e6  %96us
B_3db=abs(fd(I2(end))-fd(I2(1)))*1e-6     %0.6MHz
figure();
contour(tau*1e6,fd*1e-6,lfm,[10^(-3/20),10^(-3/20)],'g');
xlabel('\tau/us');ylabel('fd/MHz');title('ģ��������-3dB�и�ȸ���ͼ');
%%
%% ==============================1.2 ��ɻ���===================================%%
%% 64������ɻ���ǰ�������-�����ϵ����
N_pulse=theta_3dB/60/PRT;                              %�������������
R_CI=linspace(0+Ru/400,Ru,400);                        
SNR_1=10*log10(Pt_CI*taup*G^2*RCS*lambda^2)-10*log10((4*pi)^3*k*T.*(R_CI).^4)-F-L-Lp;
SNR_N=SNR_1+10*log10(N_CI);                            %��ɻ��ۺ��SNR
figure(5);plot(R_CI*1e-3,SNR_1,'b',R_CI*1e-3,SNR_N,'--r');
axis([35,80,-10,30]);
title('64��ɻ���ǰ�������-�����ϵ����');
xlabel('����/km');ylabel('SNR/dB');legend('��ɻ���ǰ','��ɻ��ۺ�');grid on;
%% %����ͼ
R=[0:10:90]; %km ��б��
phi=[0:0.1:90]'; % ����
xr_range=cos(phi/180*pi)*R; %km �Ⱦ��ߵ�x��
yr_range=sin(phi/180*pi)*R; %km �Ⱦ��ߵ�y��
Het=[5:5:30]; %km �ȸ߶�
xr_high=zeros(length(Het),length([min(Het):1:80]));
yr_high=zeros(length(Het),length([min(Het):1:80]));
for num_high=1:length(Het)
    r=[Het(num_high):1:80]; %km
    lenr_high(num_high)=length(r);
    phi_high=asin(Het(num_high)./r-r/ae/2)/pi*180; %rad ����
    xr_high(num_high,1:lenr_high(num_high))=cos(phi_high/180*pi).*r; %km �ȸ��ߵ�x��
    yr_high(num_high,1:1:lenr_high(num_high))=sin(phi_high/180*pi).*r; %km �ȸ��ߵ�y��
end
%-------------------------------��������----------------------------------------%
r_ele=[0:1:80]; %km �������ߵľ�����ɢ
Lenr_ele=length(r_ele);
Phi=cat(1,[0:2:24]',[28:4:40]',[50 :10 :90]'); %degree ������ 
xr_ele=cos(Phi/180*pi)*r_ele; %km �ȸ��ߵ�x��
yr_ele=sin(Phi/180*pi)*r_ele; %km �ȸ��ߵ�y��
%-------------------------------����ͼ----------------------------------------%
phi=[0:0.1:90]; %degree ��������ɢ
gf = exp(-1.3863*((phi-phi0)/10).^2); %��˹�ͷ���ͼ
Gt=gf*10^(Gt_dB/10); % ���䷽��ͼ
Gr=gf*10^(Gr_dB/10); % ���շ���ͼ
Simin=-114+10*log10(B)+10*log10(F)+10*log10(D0); %dBm ������
R4=Pt*taup*Gt.*Gr*lambda^2*RCS/( (4*pi)^3*10^((Simin/10-3)*10^(L/10)) ); % ����
Rcover=R4.^(1/4)/1000; %km �״�����ͼ
Rcover=Rcover/max(Rcover)*60;
xr_cover=cos(phi/180*pi).*Rcover; %km ����ͼ��x��
yr_cover=sin(phi/180*pi).*Rcover; %km ����ͼ��y��
figure(6)
for num_range=1:length(R) % �Ⱦ���
    plot(xr_range(:,num_range),yr_range(:,num_range),'g-'),hold on
end
for num_high=1:length(Het) % �ȸ���
    plot(xr_high(num_high,1:lenr_high(num_high)),yr_high(num_high,1:lenr_high(num_high)),'k-'),hold on
end
num_text=zeros(1,length(Phi));
for num_ele=1:length(Phi) % ��������
    for m=1:Lenr_ele
        if (xr_ele(num_ele,m)<70 && xr_ele(num_ele,m+1)>=70) || (yr_ele(num_ele,m)<22 && yr_ele(num_ele,m+1)>=22)
            num_text(num_ele)=m;
            break;
        end
    end
    plot(xr_ele(num_ele,:),yr_ele(num_ele,:),'b-'),hold on
    
end

plot(xr_cover,yr_cover,'r','LineWidth',2)
title('�״�����ͼ')
xlabel('���루km��'),ylabel('�߶ȣ�km��')
axis([0 70 0 22])                    %�������������ֵ
%�Ե�����������ע
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
%% ===============================1.3 ƥ���˲�����===============================%%
PluseWidth = 160e-6;           %%������
Fs = 2e6;                      %%������
Br = 1e6;                      %%��Ƶ����
gama = Br/PluseWidth;           %%����ϵ��
tp_nrn = floor(PluseWidth*Fs/2)*2;%%��0ȡ��--���������
t = (-tp_nrn/2:tp_nrn/2-1)/Fs;    %%�������ʱ������
freq = linspace(-0.5*Fs,0.5*Fs,tp_nrn);
x = exp(1j*pi*gama*t.^2);  %%LFM
h = conj(fliplr(x));       %%ƥ���˲���
h1 = h .* taylorwin(tp_nrn,4,-35).';%-35dB̩�մ�,Ƶ��Ҳ�൱�ڼӴ�
h2 = h .* hamming(tp_nrn).';
N = (length(x)+length(x));%�����ϴ�������
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
%% ƥ�亯��ʵ�����鲿
figure;
plot(t,real(h),'r',t,imag(h),'b--');
xlabel('ʱ��/s');ylabel('����');title('ƥ�亯��ʵ�����鲿');
axis([-80e-6 80e-6 -inf inf]);
grid on;
figure;
plot(freq,abs(fftshift(fft(h))));
xlabel('Ƶ��/Hz');ylabel('����');title('ƥ�亯��Ƶ��');
axis tight;grid on;%%ʹ������������Сֵ��������ݷ�Χһ��
%% ��ѹ���
figure;
plot(tt,20*log10(abs(y)),'r',tt,20*log10(abs(y1)),'g',tt,20*log10(abs(y2)),'k');
xlabel('ʱ��/us');ylabel('��һ����ֵ/dB');title('��ѹ���');
legend('���Ӵ�','taylorwin','Hamming');
axis([-inf inf -60 0]);
grid on; 
%%  �Ӵ�ϸ�ڶԱ�
figure();
plot(tt,20*log10(abs(y)),'r',tt,20*log10(abs(y1)),'g',tt,20*log10(abs(y2)),'k');
axis([150 170 -60 0]);
xlabel('ʱ��/us');ylabel('��һ����ֵ/dB');title('��ѹ���');
legend('���Ӵ�','taylorwin','Hamming');
clear N
%%
%%============================= ����M���� ================================%%
primpoly(7,'all');                %%7��M���е����б�ԭ����ʽ
fbconnection = [1 0 0 0 0 0 1];   %��λ�Ĵ����ĳ�ʼ״̬
n = length(fbconnection);
N = 2^n-1;
register = [zeros(1,n-1) 1];  
mseq(1) = register(n);
for i = 2:N
    newregister(1) = mod(sum(fbconnection.*register),2);%%ȡģ
    for j = 2:n
        newregister(j) = register(j-1);%%register(1,n-1)
    end
    register = newregister;
    mseq(i) = register(n);
end
mseq = 2*mseq-1;
clear N
%%
%% ========================== M������ѹ =========================%%
code = mseq;
Tp0 = 1e-6;%%ÿ����Ԫ��������
Ts = 1/Fs;
R0 = [40e3 60e3 80e3];
Vr = [0 50 500];
SNR = [10 10 10];
Rmin = 30e3;%%�ٶ�����������ź���30kmλ��Ϊ�ο�  %%��������С����
Rrec = 150e3;%%���վ��봰�Ĵ�С
bos = 2*pi/0.03;
M = round(Tp0/Ts);%%ÿ����Ԫ�ڵĲ�������
code2 = kron(code,ones(1,M));%��չ��Ԫ����ʱ�䣬��֤�������屻M��������ȵ���
C = 3e8;
NR1 = 2^nextpow2(2*Rrec/C/Ts); %���봰�ڶ�Ӧ�Ĳ�������  
M2 = M*length(code);           %һ��������ռ��Ԫ��
t1 = (0:M2-1)*Ts;              %��������һ�������
sp = (0.707*(randn(1,NR1)+1j*randn(1,NR1)));%���봰�ڼ���
%%���Ŀ����Ϣ
for k = 1:length(R0)
    NR = fix(2*(R0(k)-Rmin)/C/Ts);%%����ȡ��  ת��Ϊ������
    Ri = 2*(R0(k)-Vr(k)*t1);
    spt = (10^(SNR(k)/20))*exp(-1j*bos*Ri).*code2;%���ò����ĸ���
    sp(NR:NR+M2-1) = sp(NR:NR+M2-1)+spt;
end
rr = linspace(Rmin,Rmin+Rrec,length(sp))/1000;%����ȫ��Ӧ
rr_1 = linspace(Rmin,Rmin+Rrec,length(sp)+254);
spf = fft(sp,NR1+254);%ֱ��ȡ�źŵĳ��ȣ�ƥ���˲������Ⱥ���   ����Ϊ2048
Wf_t = fft(conj(fliplr(code2)),NR1+254);%��ʱ�䷴��          ����Ϊ254
y = abs(ifft(spf.*Wf_t,NR1+254));
result = y(255:254+NR1);
%% �볤Ϊ127��M����
figure;
plot(t1*1e6,real(code2));%%ת����λΪ΢��
grid on;
xlabel('ʱ��/us');ylabel('ƥ�亯��ʵ��/V');title('�볤Ϊ127��M����');
%% �ز��ź�ʵ��
figure;
plot(rr,real(sp));
grid on;
xlabel('����/km');ylabel('�ز��ź�ʵ��/V');title('�ز��ź�');
%% �ٶ�Ϊ[0,50,100]m/s����ѹ���
figure;
plot(rr,20*log10(abs(result)));
grid on;
xlabel('����/km');ylabel('��ѹ���/dB');title('�ٶ�Ϊ[0,50,100]m/s����ѹ���');
axis([30 140 0 60]);
clear t1 R0 rr y

%% ================================1.4 �������źŴ���========================================%%
%% ԭʼ�ز������ź�
Echo=zeros(1,fix(PRT*Fs));DelayNumber=fix(2*Ru/C*Fs);
Echo(1,(DelayNumber+1):(DelayNumber+length(x)))=x;%�����ز��ź�
V=Vs*cos((alpha+beta)/180*pi) ;                   %Ŀ���뵼������ٶ�  Ŀ�꺽��Vs=5m/s
Signal_ad=2^8*(Echo/max(abs(Echo)));              %�źž���ad�� 1*1600
t_N=0:1/Fs:N_CI*PRT-1/Fs;                         %N_CI=64  ���������� 1*102400
Signal_N=repmat(Signal_ad,1,N_CI);                %64�����ڻز�(������) 1*1600*64=102400
Signal_N=Signal_N.*exp(1j*2*pi*(2*V/lambda)*t_N); %���������Ƶ�� 1*102400
Noise_N=1/sqrt(2)*(normrnd(0,2^10,1,N_CI*nTr)+1j*normrnd(0,2^10,1,N_CI*nTr));   % �����ź�
Echo_N=Signal_N+Noise_N;                                                        %��������Ļز��ź�
Echo_N=reshape(Echo_N,nTr,N_CI);                                                %1600*64
figure(12);mesh((0:nTr-1)/Fs*C/2*1e-3,0:63,abs(Echo_N.'));title('ԭʼ�ز������ź�');  %�ز������ź�ͼ��
xlabel('���뵥Ԫ/Km');ylabel('�����յ�Ԫ');zlabel('����');grid on;
%% ����άԭʼ�ز��Ļ����ź�
figure();
plot(abs(Echo_N));
%%  �ز��ź���ѹ
t=(-nTe/2:(nTe/2-1))/nTe*taup;
f=(-256:255)/512*(2*BW);
Slfm=exp(1j*pi*mu*t.*t);                    %���Ե�Ƶ�ź�
Ht=conj(fliplr(Slfm));    
Echo_N_fft=fft(Echo_N,2048);  
Ht=conj(fliplr(Slfm));    %�ز��ź�FFT 2048*64
Hf_N=fft(Ht,2048);                                        %Ƶ����ѹϵ��
Hf_N=repmat(Hf_N.',1,N_CI);                               %��ѹϵ������ 2048*64
Echo_N_temp=ifft(Echo_N_fft.*Hf_N);                       %Ƶ����ѹ��δȥ��̬��   1600*64
Echo_N_pc=Echo_N_temp(nTe:nTe+nTr-1,:);                   %ȥ����̬�� 
figure();
plot((0:nTr-1)/Fs*C/2*1e-3,20*log10(abs(Echo_N_pc)));
title('�ز��ź���ѹ');xlabel('���뵥Ԫ/km');ylabel('����/dB');
%% �ز��ź���ѹ�ֲ�ͼ
figure();
plot((0:nTr-1)/Fs*C/2*1e-3,20*log10(abs(Echo_N_pc)));
axis([72 85 80 105]);
title('�ز��ź���ѹ�ֲ�ͼ');
xlabel('���뵥Ԫ/km');ylabel('����/dB');
%% 64������ɻ��۽��
Echo_N_mtd=fftshift(fft(Echo_N_pc.'),1);%64������ɻ��ۺ�MTD
figure(14);mesh((0:nTr-1)/Fs*C/2*1e-3,(-32:31)/PRT/64,(abs(Echo_N_mtd)));
xlabel('����/Km');ylabel('������Ƶ��/Hz');zlabel('����(dB)');grid on;title('64������ɻ��۽��');set(gcf,'color',[1,1,1])
%% %�ȸ�ͼ
figure;contour((0:nTr-1)/Fs*C/2*1e-3,(-32:31)/PRT/64,((abs(Echo_N_mtd))));
 axis([75 85 220 340]);
xlabel('����/Km');ylabel('������Ƶ��/Hz');zlabel('����/dB');grid on;title('64������ɻ��۵ȸ���ͼ');
%% ���ۼ���ֵ
[index_i index_j]=find(abs(Echo_N_mtd)==max(max(abs(Echo_N_mtd)))); 
%�����ֵ�����յ�Ԫ��Ӧ���ظ����ڽ���CFAR���� index_i=1��index_j=1067 ��������fd�;���rת���ɾ�����
V_fd=2*V/lambda     ;                            %���������Ķ�Ӧ�Ķ�����Ƶ�� V=12.8575m/s Ŀ���뵼������ٶ�
mtd_fd=(index_i-1)/PRT/64 ;                      % ��λ��۶�Ӧ�Ķ�����Ƶ�� mtd_fd=0Hz
SNR_echo=20*log10(2^8/2^10)                      %ԭʼ�ز������ź������   
SNR_pc=SNR_echo+10*log10(BW*taup)                %��ѹ�������
SNR_ci=SNR_pc+10*log10(64) %64������ɻ��ۺ������ 

%%
%% ----------------------------���龯--------------------------------% 
%% ���龯��ƽ
N_mean=8;                                                                          %�ο���Ԫ M=8
N_baohu=4;                                                                         %������Ԫ N=4
K0_CFAR=(1/P_fa)^(1/N_mean)-1         %K��ֵ����                                    %����ϵ��K=3.2170 
CFAR_data=abs(Echo_N_mtd(index_i,:));                                              %�ź� 1*1600��ȡ���ֵ���ڶ�����ά����index_i=1��
K_CFAR=K0_CFAR./N_mean.*[ones(1,N_mean/2) zeros(1,N_baohu+1) ones(1,N_mean/2)];    %���龯ϵ������ 1*13
CFAR_noise=conv(CFAR_data,K_CFAR);                                                 %���龯���� 13+1600-1=1612 
CFAR_noise=CFAR_noise(length(K_CFAR):length(CFAR_data)); 
%ȥ��̬�� [13��:1600] ��Ϊ���߸�����4���ο���Ԫ��2��������Ԫ������ʵ�ʽ���CFAR�ĵ��ǡ�7:1594��
figure(15);
plot(((N_mean+N_baohu)/2+1:nTr-(N_mean+N_baohu)/2)/Fs*C/2*1e-3,CFAR_noise,'r-.');  %���龯��ƽ  ��7:1594��
hold on;plot((0:nTr-1)/Fs*C/2*1e-3,CFAR_data,'b-');                                %�ź�
xlabel('����/Km');ylabel('����');grid on;title('���龯����');legend('���龯��ƽ','�źŵ�ƽ');hold off

%%
hold on;plot((0:nTr-1)/Fs*C/2*1e-3,CFAR_data,'b-');  
axis([74 90 0 5e6]);%�ź�
xlabel('����/Km');ylabel('����');grid on;title('���龯����');legend('���龯��ƽ','�źŵ�ƽ');
%hold off
%%