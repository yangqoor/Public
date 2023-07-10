%% =========================�ִ��״�ϵͳ���������=======================%%
%%���ߣ�
% -----------------------------�ڶ���------------------------------------%
clear;close all;
%% ��������
load('IQ_data.mat');   %��������         
C = 3e8;               %����           
lamda = 1.25;          %����      
Pfa = 10e-6;           %���龯��        
Ts = 1e-6;             %��������          
Fs = 1/Ts;             %%������
BandWidth = 8e5;       %LFM����                    
PulseWidth = 420e-6;   %%������                  
gama = BandWidth/PulseWidth;       %% %LFM��Ƶϵ��                  
AntennaSpacing  = 0.625;           %��Ԫ���벨��           
AntennaCount  = 20;                %20����������Ԫ
PulseCount  = 12;                  %������,���Ƿ�λ�������
SampleNumber  = 3000;              %ȡ����

%% ===========================2.1 DBF =============================%%
theta0 = 0; %����ָ��
DirectionVector = exp(1j*2*pi/lamda*(0:AntennaCount -1)'*AntennaSpacing *sin(theta0));%����ʸ��20*1
Taylor_DBF = taylorwin(AntennaCount ,5,-25);%-25dB taylorwin
DirectionVector = DirectionVector.*Taylor_DBF;%��������
DBF_Result = zeros(SampleNumber ,PulseCount );
for i = 1:SampleNumber 
    for k = 1:PulseCount 
        DBF_Result(i,k) = IQ_mid(i,:,k)*DirectionVector;%3000*12
    end
end
figure;
plot(20*log10(abs(DBF_Result)));%%Ĭ�ϰ��л�
xlabel('���뵥Ԫ');ylabel('�źŷ���/dB');title('DBF�����̩�մ���');
axis([0 3000 80 170]);grid on;
grid on;

%% ===================== 2.2 ��ѹԭʼ��Ƶ =====================%%
SmpCount = floor(PulseWidth*Fs/2)*2;%����ʱ���Ӧ������ 420
Smp_Time = (-SmpCount/2:SmpCount/2-1)'/Fs;%420*1
win_r = taylorwin(SmpCount,9,-35);%-35dB̩�մ�
h = exp(1j*pi*gama*Smp_Time.^2);%ƥ���˲���������Ƶ��
h = h.*win_r;%�Ӵ�
H = fft(h,2^nextpow2(SampleNumber +length(h)));
PC_Result = zeros(2^nextpow2(SampleNumber ),PulseCount );
for i = 1:PulseCount 
    PC_Result(:,i) = ifft(fft(DBF_Result(:,i),2^nextpow2(SampleNumber +length(h))).*H);
end
figure;
plot(20*log10(abs(PC_Result(:,:))));
xlabel('���뵥Ԫ');ylabel('�źŷ���/dB');title('��ѹ�����̩�մ���');
axis([0 3000 80 180]);grid on;

%% ==========================2.3 zero_MTI ==========================%%
FilterOrder = 6;%���Ӳ��˲�������
T_Vector = [4.1e-3  4.3e-3  4.5e-3];%��T 187:200:213  %%����
fr = 1/mean(T_Vector);
T_Count = length(T_Vector);%���Ӳ��˲�������
zero_freq = [-1 -0.5 0 0.5 1];

f = [-100:0.1:100 101:1:2000];%Ƶ�ʷ�Χ,�Ǿ���
Coeff_Count = FilterOrder-1;
tao_T = repmat(T_Vector,1,Coeff_Count);%����A���� ����Ȩֵ
w = zeros(1,FilterOrder);
w(1) = 1;%w0=1
U = [1;zeros(Coeff_Count-1,1)];
A = zeros(Coeff_Count,Coeff_Count);
Ti = zeros(1,FilterOrder);
ww = zeros(T_Count,FilterOrder);
hd = 1;
%%���Ȩϵ��w
for uu = 1:length(zero_freq)
for m = 1:T_Count  %��ͬ�ӳ�״̬���˲����״̬011 101 110...
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
    ww(m,:) = ww(m,:)/max(abs(ww(m,:)));%��������һ��
    hd0(m,:) = ww(m,:) * exp(-1j*2*pi*Ti'*f);
end
hd = hd .* hd0;
end
hd(m+1,:) = mean(abs(hd(1:m,:)));
hd = hd.^(1/length(zero_freq));
Hd = 20*log10(abs(hd));
figure;
plot(f,Hd);
xlabel('Ƶ��/Hz');ylabel('|H(f)|/dB');title('MTI�˲�����Ƶ����');
legend('T1:T2:T3','T2:T3:T1','T3:T2:T1','ƽ��');    
axis([-100 2000 -inf 20]);grid on;
%% ============================2.4 MTI =============================%%
sig_mti = zeros(SampleNumber ,PulseCount -FilterOrder+1);%�������ĳ���Ϊ4��6����һ����λ��������Ϊ12
                                  %��sig��2^nextpow2(SampleNumber )-3000����
for k = 1:PulseCount -FilterOrder+1
    n = mod((k-1),3)+1;%Ĭ�ϲ�λ�е�һ�����尴T1,T2,T3����
    sig_mti(:,k) = PC_Result(1:SampleNumber ,k+(1:FilterOrder)-1) * ww(n,:).';
end
figure;
plot(20*log10(abs(sig_mti)));
xlabel('���뵥Ԫ');ylabel('�źŷ���/dB');title('MTI��ԭʼ��Ƶ');
axis([0 3000 80 180]);grid on;
%% ============================2.5 CFAR ============================%%
sig0 = mean(abs(sig_mti),2);%����ɻ���
%%CFAR���龯
pro_cell = 1;                 %������Ԫ��
left_cell = 4;
right_cell = 4;               
K0 = (1/Pfa)^(1/(left_cell+right_cell))-1;% ����ϵ��K0
cfar = zeros(SampleNumber ,1);
%���޼���
for i = pro_cell+left_cell+1 : SampleNumber -right_cell-pro_cell
    cfar(i) = ( sum(sig0(i-pro_cell-left_cell:i-pro_cell-1,1)) ...%��
               +sum(sig0(i+pro_cell+1:i+pro_cell+right_cell,1)) ) ...%��
              ./(left_cell+right_cell)*K0;
end
figure; 
plot(20*log10(abs(sig0)),'b');hold on;

plot(20*log10(abs(cfar)),'r-.');
xlabel('���뵥Ԫ');ylabel('�źŷ���/dB');title('����ɻ���ԭʼ��Ƶ��CFAR����');
axis([500 3000 120 170]);
legend('ԭʼ�ź�','CFAR����');
hold off;grid on;
%% CFAR �ֲ�ͼ
figure; 
plot(20*log10(abs(sig0)),'b');hold on;
plot(20*log10(abs(cfar)),'r-.');
xlabel('���뵥Ԫ');ylabel('�źŷ���/dB');title('����ɻ���ԭʼ��Ƶ��CFAR����');
axis([800 1350 120 170]);
legend('ԭʼ�ź�','CFAR����');
hold off;grid on;
%%