%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                      SAR imaging: RD_algorithm (2010.08)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;
close all;
%%%%%% ��������
%%%%%%%%%%%%%%% constant parameters %%%%%%%%%%%%%%%%%%%

c = 3e8;                   % speed of light,3*10^8m/s

%%%%%%%%%%%%%%% chirp signal parameters %%%%%%%%%%%%%%%

fc = 1e9;                % carrier frequency,1GHz
wc = 2 * pi * fc;
lambda = c / fc;           % Wavelength at carrier frequency
Tr = 1.5e-6;               % chirp pusle duration 1.5us
Br = 150e6;                % chirp frequebcy bandwidth 150Mhz
Kr = Br/Tr;                % chirp signal: frequency modulation rate

%%%%%%%%%%%%%% observating strip parameters %%%%%%%%%%%%

H = 3000;                          % ����ƽ̨�ĸ߶�
ThetaCenter = 45 / 180 * pi;       % ������SARϵͳ��б�ӽǣ����� ���ؽǵ����
Platform_center = [0, 0, H];       % ����ƽ̨��λ������

Y_C = H * tan(ThetaCenter);
Scene_center = [0, Y_C, 0];        % �������ĵ�λ������
delta_X = 150;                     % ��������ķ�Χ��x���꣨ƽ̨���з���
delta_Y = 100;                     % ��������ķ�Χ��y����
Xmin = -delta_X / 2;
Xmax = delta_X / 2;
Ymin = -delta_Y / 2;
Ymax = delta_Y / 2;
RC0 = sqrt(sum((Scene_center - Platform_center) .^2));  %����ƽ̨���ĵ��������ĵľ���

%%%%%%%%%%%%%% performance parameters %%%%%%%%%%%%%%%%%%

rho_R = c / (2 * Br);             % ����ֱ��ʣ�m��
roh_Y = rho_R / sin(ThetaCenter); % ͸�ӽ�������к�����(CT)�ֱ��ʣ�m��
rho_AT = rho_R;                   % �غ�����(AT)�����۷ֱ��ʣ�m��

V = 150;                         % ����ƽ̨���ٶȣ�x�᣺m/s��
D = 2 * rho_AT;                  % �غ������ʵ���߿׾����ȣ�page 63, function(3.27)
Lsar = lambda * RC0 / D;         % AT��һ���ϳɿ׾��ĳ���; page 59, function(3.14)
Tsar = Lsar / V;                 % һ���ϳɿ׾�ʱ��

%%%%% fast-time sampling sequence

Rate_Fs = 1.2;                   % ��ʱ����Ĺ�����ϵ��Ϊ1.2
Fs = round(Rate_Fs * Br);        % ����ά�Ĺ������ʣ�˫ͨ����ʵ����I�� �鲿��Q��
Ts = 1 / Fs;                     % ��ʱ�����ʱ����
delta_Rs = Ts * c;               % ��ʱ����������Ӧ�ľ��볤��

Rmin = sqrt((Y_C + Ymin)^2 + H^2);                  % ������̾���
Rmax = sqrt((Y_C + Ymax)^2 + (Lsar/2)^2 + H^2);     % ����������
Nfast = ceil((2 * (Rmax-Rmin) / c + Tr) / Ts);      % ������Ĳ��������
Nf = 2^nextpow2(Nfast);                             % for fft
tf_org = [-Nf/2 : (Nf/2 - 1)] * Ts;                 % �����ʱ���������
% tff = tf_org*c;
% tr_ff = (tff/2 + RC0) / sin(pi/4); 
tf = (2 * RC0 / c) + tf_org;                        % ʵ�ʿ�ʱ�����ֵ
tr = tf * c / 2;                                    % ��ʱ�������Ӧ�ľ�����(���̾�)

%%%%% slow-time sampling sequence

Ka = -2 * V^2 / (lambda * RC0);  % �����յ�Ƶ��,(��SAR��p159, func(6.5))
Ba = abs(Ka * Tsar);             % �����մ���
Rate_PRF = 1.25;                 % ��ʱ����Ĺ�����ϵ��Ϊ1.25
PRF = round(Rate_PRF * Ba);      % �����ظ�Ƶ��
PRT = 1 / PRF;                   % �����ظ�����,��һ�������ظ������ڣ��ɻ��ķ���ʱ������

Nslow = ceil((delta_X + Lsar) / V / PRT);            % ��λ����������
Ns  = 2^nextpow2(Nslow);                             % �Ż�����������for fft��
% Ns  = Nslow;
ts = (-Ns/2 : (Ns/2 - 1)) * PRT;                     % ��ʱ���������
ta = ts * V;                                         % ��ʱ�������Ӧ�ľ�����

%%%%%
% % delta_d_AT = lambda;           % AT�����Ԫ�������SARԭ���γɣ�
% % PRF = round(V / delta_d_AT);   % �����ظ�Ƶ��
% % p = nextpow2(A) returns the smallest power of two that is greater than or equal to the absolute value of A.
% X_start = Xmin - Lsar/2;                             % ������Χ��x����Сֵ
% X_end = Xmax + Lsar/2;                               % ������Χ��x�����ֵ
% ts = linspace(X_start / V, X_end / V, Ns);           % �Է�λ��ʱ�����
% % temp_ts = diff(ts);
% % PRT = sum(temp_ts(:)) / length(temp_ts);               % ��ɢ�������ظ�����
% dts = ts(2) - ts(1);              % ��ɢ�������ظ�����
% Fsa = 1/dts;                      % �����ظ�����
% delta_d_AT = V * Fsa;             % AT�����Ԫ���

%%%%%%%%%%%%% SAR��Resolution  %%%%%%%%%%%%%%%%%%%%%%%%%

% Dr=c/2/Br;                      % range resolution
% Dx=v/Ba;                        % cross-range resolution

%%%%%%%%%%%% set point targets parameters %%%%%%%%%%%%%%%

% format [x, y, z, RCS]          
Ptargets = [  0,   0,   0,   1/2  %];               
            -20,   0    0,   1/2
             50,   0    0,   1/2
              0,  20,   0,   1/2
             20,  20,   0,   1/2];   % �����Ŀ������λ�ü�����ɢ��ϵ��

Ntar = size(Ptargets, 1);          % ��Ŀ�����
Ptargets(:, 1:3) = Ptargets(:, 1 : 3) + ones(Ntar, 1) * Scene_center;  % ��Ŀ�����ʵ����λ��

%%%%%%%%%%%%%%%%%%%  Show the targets  %%%%%%%%%%%%%%%%%%%

figure;
plot(Ptargets(:, 1), Ptargets(:, 2), 'o','MarkerEdgeColor','b','MarkerFaceColor','g'); %, 'MarkerSize', 12
grid on
% axis equal;
axis([Scene_center(1)+Xmin Scene_center(1)+Xmax Scene_center(2)+Ymin Scene_center(2)+Ymax]);
xlabel('x��(AT��)'); 
ylabel('y��(CT��)');
title('�۲ⳡ������Ŀ��');

%=========================================================================%
%=========================================================================%

%%%%%%%%%%%%%%%%%%  Show the launch signal %%%%%%%%%%%%%%%%%
% figure;
% duty = Tr/PRT*100;
% A0 = 1;
% t = 0:Ts:4*PRT;
% rect = A0/2*square(2*pi*PRF*t,duty)+A0/2;
% subplot(2,2,1);
% plot(t,rect);
% grid on;
% axis([0 4*PRT -0.1 A0+0.2]);
% xlabel('x��-ʱ��');
% ylabel('y��-����');
% title('���β���4�����ڣ�');
% 
% t = 0:Ts:2*Tr;
% signal_car = cos(2*pi*fc*t);
% subplot(222);
% plot(t,signal_car);
% grid on;
% axis([0 2*Tr -1.2 1.2]);
% xlabel('x��-ʱ��');
% ylabel('y��-����');
% title('�ز����ֲ� ʱ��2���������ʱ�䣩');
% 
% t = 0:Ts:2*Tr;
% signal_mod = cos(2*pi*fc*t+Kr*t.*t);
% subplot(223);
% plot(t,signal_mod);
% grid on;
% axis([0 2*Tr -1.2 1.2]);
% xlabel('x��-ʱ��');
% ylabel('y��-����');
% title('�ز�+���Ե�Ƶ�����ֲ� ʱ��Ϊ2���������ʱ�䣩');
% 
% signal_launch = rect(1:size(signal_mod,2)).*signal_mod;
% subplot(224);
% plot(t,signal_launch);
% grid on;
% axis([0 2*Tr -1.2 1.2]);
% xlabel('x��-ʱ��');
% ylabel('y��-����');
% title('�����źţ��ֲ� ʱ��Ϊ2���������ʱ�䣩');


%=========================================================================%
%=========================================================================%
disp('*********************************************************');
fprintf(1,'ϵͳ������ʾ���棺\n');
fprintf(1,'\n');
disp(['��ʱ�������������:', poly2str(Nf)]);
disp(['��ʱ����Ĺ���������:', poly2str(Rate_Fs)]);

disp(['PRF:', poly2str(PRF)]);
disp(['��ʱ�������������:', poly2str(Ns)]);
disp(['��ʱ����Ĺ���������:', poly2str(Rate_PRF)]);

disp(['AT��ϳɿ׾��ĳ�����:', poly2str(Lsar), ' m']);
disp(['������ķֱ�����:', poly2str(rho_R), ' m']);
disp(['�غ���ķֱ�����:', poly2str(rho_AT), ' m']);
fprintf(1,'\n');
disp('*********************************************************');
          
%=========================================================================%
%=========================================================================%

%%%%%%%%%%%%%%  Generate the raw signal data  %%%%%%%%%%%%%%%%%%%

Echo_data = zeros(Ns, Nf);                  % ��ʼ���ز�������
for ii = 1 : Ntar
    sigma = Ptargets(ii, 4);                % ��ȡ����ϵ��
    Xslow = ts .* V - Ptargets(ii, 1);                                % �״�����ʱ����ƶ����룬XslowΪ1��Ns�ľ���
    Yslow = Platform_center(2) - Ptargets(ii, 2);
    Zslow = Platform_center(3) - Ptargets(ii, 3);
    R = sqrt(Xslow.^2 + Yslow^2 + Zslow^2); % �״���Ŀ��ľ���
    tau = 2 * R / c;                        % �ź���˫�̵�����ʱ��tauΪ1*N�ľ���
    Dfast = ones(Ns,1) * tf - tau' * ones(1, Nf);                      % �״����Ŀ���ƶ��ڿ�ʱ�������ʱ��tmΪ1*M�ľ���Dfast��ΪN*M�ľ���
    phase = pi*Kr*Dfast.^2 - (4 * pi / lambda * R') * ones(1,Nf);     % ��һ����ָ�ź���˫�̵�����ʱ����������λ�ӳ٣��ڶ���ָ˫�̾���R����������λ�ӳ�
    Echo_data = Echo_data + sigma * exp(1i*phase) .* (abs(Dfast) <= Tr/2) .* ((abs(Xslow) <= Lsar/2)' * ones(1,Nf));
    
    %%%%%%%%%%%%%%%%%%%%% Show the perproity about targets %%%%%%%%%%%%%%%%%%%%%%%
    
%     figure;
%     subplot(221);
%     plot(ts,abs(Xslow));
%     grid on;
%     xlabel('X�ᣭʱ��');
%     ylabel('Y�ᣭֵ');
%     title(['X������-Ŀ�� ' num2str(ii)]);
%     
%     subplot(222);
%     plot(ts,R);
%     grid on;
%     xlabel('X�ᣭʱ��');
%     ylabel('Y�ᣭֵ');
%     title(['�״���Ŀ�����-Ŀ�� ' num2str(ii)]);
%     
%     subplot(223);
%     plot(tr,tf);
%     grid on;
%     xlabel('X�ᣭʱ��');
%     ylabel('Y�ᣭֵ');
%     title(['��ʱ�����ʱ��-Ŀ�� ' num2str(ii)]);
%     
%     subplot(224);
%     plot(ts,tau);
%     grid on;
%     xlabel('X�ᣭʱ��');
%     ylabel('Y�ᣭֵ');
%     title(['��ʱ��ʱ���-Ŀ�� ' num2str(ii)]);
%     
%     figure;
%     xx = ta;
%     yy = Y_C + (tr-RC0) ./ sin(ThetaCenter);
%     [x,y] = meshgrid(xx,yy);
%     subplot(221);
%     mesh(x,y,tau' * ones(1, Nf));
%     xlabel('X�ᣭ��λ��');
%     ylabel('Y�ᣭ������');
%     title(['��ʱ���ӳ�-Ŀ�� ' num2str(ii)]);
%     
%     subplot(222);
%     mesh(x,y,ones(Ns,1) * tf);
%     xlabel('X�ᣭ��λ��');
%     ylabel('Y�ᣭ������');
%     title(['ʱ�����-Ŀ�� ' num2str(ii)]);
%     
%     subplot(223);
%     mesh(x,y,phase);
%     xlabel('X�ᣭ��λ��');
%     ylabel('Y�ᣭ������');
%     title(['��λ-Ŀ�� ' num2str(ii)]);
%     
%     subplot(224);
%     mesh(x,y,abs(Echo_data));
%     xlabel('X�ᣭ��λ��');
%     ylabel('Y�ᣭ������');
%     title(['�ز�-Ŀ�� ' num2str(ii)]);
    
  
    
    
    
end

%%%%%%%%%%%%%%%%%   Range compression   %%%%%%%%%%%%%%%%%%%%%%

%%%%% ������
% WinTr = (abs(tf_org) <= Tr/2);
% WinIndex = find(WinTr ~= 0);
% WinLength = length(WinIndex);
% WinStart = min(WinIndex(:));
% WinEnd = max(WinIndex(:));
% WindowTr = zeros(size(tf));
% WindowTr(1, WinStart : WinEnd) = hamming(WinLength).';
% % figure,plot(WindowTr);
% h_ref = exp(j * pi * Kr * tf_org.^2) .* WindowTr;                     % ������ο�����,ʱ��

h_ref = exp(1i * pi * Kr * tf_org.^2) .* (abs(tf_org) <= Tr/2);          % ������ο�����,ʱ��
h_ref = h_ref .* (hamming(Nf).');                                       % �Ӵ���Ĳο�����
H_ref = fty(ones(Ns, 1) * h_ref);
% f = linspace(-Fs/2,Fs/2,Nf);
% H_ref = ones(Ns, 1) * exp(1i*pi*f.^2/Kr);
figure, plot(abs(H_ref(2, :)));
title('�ο�������Ƶ��');

Comp_f = fty(Echo_data) .* conj(H_ref);                                 % ����ѹ����Ƶ����ʽ
Comp_tsf = ifty(Comp_f);                                                % ����ѹ���ġ���ʱ��-��ʱ�䡱����ʽ��ts-tf��
Comp_Rfd = ftx(Comp_tsf);                                               % Azimuth FFT and Range-Doppler domain (fd-tf)
figure, plot(abs(Comp_tsf(Ns/2, :)));
title('����ѹ��������ݳ��');

%%%%%%%%%%%%%   �����������㶯��У�� -- RCMC   %%%%%%%%%%%%%%%%%%

fd_r = [-Nf/2 : (Nf/2 - 1)] * Fs / Nf;
FF = ones(Ns, 1) * fd_r;                                 % FFΪN*M�ľ���
fdc = 0;                                                 % doppler center
fd_a = [-Ns/2 : (Ns/2 - 1)] * PRF / Ns;
FU = fd_a.' * ones(1, Nf);
Refcorr = exp(1i * pi / fc^2 / Ka * (FU.*FF).^2 + 1i * pi * fdc^2 / fc / Ka * FF - 1i * pi / fc / Ka * FU.^2 .* FF); % Range-Doppler domain

%RCMC function

RanComff=ftx(Comp_f);                 % FFT in Azimuth 
RanComffcorr=RanComff .* Refcorr;     % RCMC
RanComtfcorr=ifty(RanComffcorr);      % data in Range_Doppler domain
RanComttcorr=iftx(RanComtfcorr);      % data in Range_Azimuth domain

%%Azimuth compression
ts_mid = ts - 0/V;                                                          % �볡���ο������ʱ��ʱ���
Refa = exp(1i * pi * Ka * ts_mid.^2) .* (abs(ts_mid) < Tsar/2);              % ��λѹ���ο�����
Sa = iftx(Comp_Rfd  .* (conj(ftx(Refa)).' * ones(1, Nf)));                  % δ���о����㶯У����ľ��뷽λѹ�����
Sa_RCMC = iftx(ftx(RanComttcorr).*(conj(ftx(Refa)).'*ones(1, Nf)));         % �Ծ����㶯У����ľ��뷽λѹ�����



%%%%%%%%%%%%%%%%%%%   ��������е�ͼ����ʾ   %%%%%%%%%%%%%%%%%%%%%
% %%%% 01 ԭʼ�ز�����
figure,
G = 20 * log10(abs(Echo_data));              % ����ɷֱ���dB������ʽ��ʾ
gm = max(max(G));
thr01 = 40;                                  % ��ʾ�Ķ�̬��Χ40dB,"thr" = threshold
g_thr = gm - thr01;
G = (G - g_thr) * (255 / thr01) .* (G > g_thr);
imagesc(tr, ta, -G);                         % ��ʾԭʼ�ز�����ͼ�� 
colormap(gray);                              % ʹ��ʾ��ͼ��Ϊ�Ҷ�ͼ��             
grid on,axis tight,
xlabel('Range')
ylabel('Azimuth')
title(['(a)ԭʼ�ź�, �������ĵĵ��̾�Ϊ��Rc = ', num2str(RC0), 'm'])
% 
%%%% 02 ����ѹ�������ݣ�δ���� RCMC ǰ��
figure;
G = 20 * log10(abs(Comp_tsf));              % ����ɷֱ���dB������ʽ��ʾ
gm = max(max(G));
thr02 = 40;                                  % ��ʾ�Ķ�̬��Χ40dB,"thr" = threshold
g_thr = gm - thr02;
G = (G - g_thr) * (255 / thr02) .* (G > g_thr);
imagesc(tr, ta, -G);
colormap(gray);                              % ʹ��ʾ��ͼ��Ϊ�Ҷ�ͼ��             
grid on,axis tight,
xlabel('Range')
ylabel('Azimuth')
title(['(b)����ѹ�����ʱ���ź�, Rc = ', num2str(RC0), 'm'])

%%%% 03 ����ѹ��������������δ���� RCMC ǰ��
figure,
G = 20 * log10(abs(Comp_Rfd));               % ����ɷֱ���dB������ʽ��ʾ
gm = max(max(G));
thr03 = 40;                                  % ��ʾ�Ķ�̬��Χ40dB,"thr" = threshold
g_thr = gm - thr03;
G = (G - g_thr) * (255 / thr03) .* (G > g_thr);
imagesc(tr, fd_a, -G);
colormap(gray);                              % ʹ��ʾ��ͼ��Ϊ�Ҷ�ͼ��             
grid on,axis tight,
xlabel('Range')
ylabel('Doppler')
title('RCMCǰ��Range Doppler domain')

%%%% 04 RCMC��: ����ѹ��������������
figure,
G = 20 * log10(abs(RanComtfcorr));           % ����ɷֱ���dB������ʽ��ʾ
gm = max(max(G));
thr04 = 40;                                  % ��ʾ�Ķ�̬��Χ40dB,"thr" = threshold
g_thr = gm - thr04;
G = (G - g_thr) * (255 / thr04) .* (G > g_thr);
imagesc(tr, fd_a, -G); 
colormap(gray);                              % ʹ��ʾ��ͼ��Ϊ�Ҷ�ͼ��             
grid on,axis tight,
xlabel('Range')
ylabel('Doppler')
title('RCMC��Range Doppler domain')

%%%% 05 δ���о����㶯У����ľ��뷽λѹ�����
figure,
G = 20 * log10(abs(Sa));                     % ����ɷֱ���dB������ʽ��ʾ
gm = max(max(G));
thr05 = 40;                                  % ��ʾ�Ķ�̬��Χ40dB,"thr" = threshold
g_thr = gm - thr05;
G = (G - g_thr) * (255 / thr05) .* (G > g_thr);
imagesc(tr, ta, -G);
colormap(gray);                              % ʹ��ʾ��ͼ��Ϊ�Ҷ�ͼ��             
grid on,axis tight,
xlabel('Range')
ylabel('Doppler')
title('05 δ���о����㶯У����ľ��뷽λѹ�����')

%%%% 06 δ���о����㶯У����ľ��뷽λѹ�����
figure,
G = 20 * log10(abs(Sa_RCMC));                % ����ɷֱ���dB������ʽ��ʾ
gm = max(max(G));
thr06 = 40;                                  % ��ʾ�Ķ�̬��Χ40dB,"thr" = threshold
g_thr = gm - thr06;
G = (G - g_thr) * (255 / thr06) .* (G > g_thr);
imagesc(tr, ta, -G); 
colormap(gray);                              % ʹ��ʾ��ͼ��Ϊ�Ҷ�ͼ��             
grid on,axis tight,
xlabel('Range')
ylabel('Doppler')
title(['06 �Ծ����㶯У����ľ��뷽λѹ�����, Rc = ', num2str(RC0), 'm']);

%%%% 07 ͸��У��������ս��
figure,
% tr_rectify = sqrt((tr).^2 - H.^2);
% tr_rectify = Y_C + (tr-RC0) ./ sin(acos(H./(tr)));
tr_rectify = Y_C + (tr-RC0) ./ sin(ThetaCenter);
imagesc(ta, tr_rectify, -G.'); 
% imagesc( -G.'); 
colormap(gray);                              % ʹ��ʾ��ͼ��Ϊ�Ҷ�ͼ��             
grid on,axis tight,
xlabel('x�᣺AT��')
ylabel('y�᣺CT��')
title(['07 ͸��У��������ս��, Y0 = ', num2str(Y_C), 'm']);

