% RADARSAT-1�����ݴ���֮RDA����SRC2
% ��ȷʵ�ֶ��ξ���ѹ����RDA

clc;clear all;close all;

%% ��ȡԭʼ����
run specify_parameters.m
run extract_data.m
clear all;

%% ��������
% �״����
C = 2.9979e8;                                                               % ����
f0 = 5.3e9;                                                                 % ����Ƶ��
lambda = C/f0;                                                              % ����
% ����ƽ̨
V = 7062;                                                                   % ƽ̨�ٶ�
% ������
Kr = -0.72135e12;                                                           % ��Ƶ��
Tr = 41.75e-6;                                                              % �������ʱ��
Fr = 32.317e6;                                                              % �����������
dtau = 1/Fr;                                                                % ���������ʱ����
% ��λ��
Ka = 1733;                                                                  % ��λ���Ƶ��
Fa = 1256.98;                                                               % ��λ�������
fc = -6900;                                                                 % ����������Ƶ��
deta = 1/Fa;                                                                % ��λ�����ʱ����
% ��������
t0 = 6.5956e-3;                                                             % ��ȡ����ʱ��
R0 = t0*C/2;                                                                % ���б��

%% ��ȡԭʼ����
oldFolder = cd('.\scene01');
load CDdata1.mat;
cd(oldFolder);
a=1;
data=double(data);
[Na,Nr] = size(data);

%% ȷ���ο�����Ͳο�ʱ��
Rref = (t0+Nr/2*dtau)*C/2;                                                  % �ο�����ѡ�ڳ�����������

%% ����ĩβ����
Za = 800;                                                                   % ��λ������
Zr = ceil(Tr/dtau);                                                         % ������������ÿ���㱻��������Tr
data = cat(2,data,zeros(Na,Zr));                                            % ��������(�ұ�)
data = cat(1,zeros(Za,Nr+Zr),data);                                         % ��λ����(�Ϸ�)
Na = Na+Za;%2336
Nr = Nr+Zr;%3398

figure,imagesc(abs(data));axis image;set(gcf,'Color','w');
title('ʱ�򣺲�����ԭʼ�źŷ���');
xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');

%% ʱ���ᡢƵ��������
tau = t0+(0:Nr-1)*dtau;                                                     % ������ʱ����
ftau = ((0:Nr-1)-Nr/2)/Nr*Fr;                                               % ������Ƶ����
eta = ((0:Na-1)-Na/2)*deta;                                                 % ��λ��ʱ����
feta = fc+((0:Na-1)-Na/2)/Na*Fa;                                            % ��λ��Ƶ����

%% ���뵽��λ�����������
S0 = data.*exp(-1i*2*pi*fc*(eta'*ones(1,Nr)));                              % ������������Ƶ������(ʽ5.19)
clear data

%% RC
% ��ʽ2���������岹������DFT,�Խ��ȡ�������ʱ�䷴�ޣ�
Tref = t0+Nr/2*dtau;                                                        % ������ο�ʱ��
ht_rc = (abs((ones(Na,1)*tau)-Tref)<Tr/2).*exp(1i*pi*Kr*((ones(Na,1)*tau)-Tref).^2); % ��ʽ2��ƥ���˲���
Hf_rc = conj(fftshift(fft(fftshift(ht_rc,2),[],2),2));                      % �˲����ľ�����FFT�任
clear ht_rc
S0_rc = fftshift(fft(fftshift(S0,2),[],2),2);                               % �źŵľ�����FFT�任
clear S0
S1 = ifftshift(ifft(ifftshift(S0_rc.*Hf_rc,2),[],2),2);                     % ƥ���˲��������IFFT�任
clear Hf_rc S0_rc

figure,imagesc(abs(S1));axis image;set(gcf,'Color','w');
title('ʱ�򣺾���ѹ������źŷ���');
xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');

%% SRC���ξ���ѹ��
Sff = fftshift(fft2(fftshift(S1)));                                         % �źŵĶ�άFFT�任
WindowR = ones(Na,1)*kaiser(Nr,2.5)';                                       % ���봰
WindowA = kaiser(Na,2.5)*ones(1,Nr);                                        % ��λ��
Sff = Sff.*WindowR.*WindowA;                                                % �Ӵ�
clear WindowR WindowA
D = sqrt(1-lambda^2*feta.^2/(4*V^2));                                       % �����㶯���ӣ�ʽ6.24
Ksrc = (2*V^2*f0^3*(D'*ones(1,Nr)).^3)./(C*R0*(feta'*ones(1,Nr)).^2);       % SRC�˲����ĵ�Ƶ�ʣ�ʽ6.22
Hsrc = exp(-1i*pi*((ones(Na,1)*ftau).^2)./Ksrc);                            % SRC�˲�����ʽ6.27
clear Ksrc
S1 = Sff.*Hsrc;                                                             % �˲�
clear Sff Hsrc
Srd = ifftshift(ifft(ifftshift(S1,2),[],2),2);                              % SRCУ���������IFFT�任���任�������������
clear S1

figure,imagesc(abs(Srd));axis image;set(gcf,'Color','w');
title('RD��SRC����źŷ���');
xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');

%% RCMC
deltaR = dtau*C/2;                                                          % ������������ȼ��
deltaRCM = Rref*(1./D-1);                                                   % �����㶯����ʽ6.25
deltaRCM = deltaRCM/deltaR;                                                 % �����㶯��������
IntNum = ceil(deltaRCM);                                                    % �Ծ����㶯������ȡ��;
DecNum = IntNum-deltaRCM;                                                   % �����㶯����С����������Ϊ��1/16���ı���
Srcmc = zeros(Na,Nr);
h = waitbar(0,'Sinc��ֵ');
for ii = 1:Na
    SincVal = sinc(DecNum(ii)-4:1:DecNum(ii)+3)';                           % ���ɲ�ֵ��
    for jj = 1:Nr
        kk = jj+IntNum(ii);                                                 % ԭ�����о����㶯��λ��
        if(5<=kk && kk<=Nr-3)                                               % ��ֹ�±����
            Srcmc(ii,jj) = Srd(ii,kk-4:kk+3)*SincVal;                       % ��ֵ
        end
    end
    waitbar(ii/Na);
end
close(h);
clear deltaRCM IntNum DecNum Srd

figure,imagesc(abs(Srcmc));axis image;set(gcf,'Color','w');
title('RD��RCMC����źŷ���');
xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');

%% AC
Haz = exp(1i*4*pi*R0*(D'*ones(1,Nr))*f0/C);                                 % ��λ��ƥ���˲�����ʽ6.26
clear D
S2 = Srcmc.*Haz;                                                            % ƥ���˲�
clear Haz Srcmc
Stt = ifftshift(ifft(ifftshift(S2,1),[],1),1);                              % ��λ��IFFT�任
clear S2

%% ����ͼ��
Img = flipud(abs(Stt));                                                     % ���·�תͼ��
Ntau = round((Tr/dtau/2-1)/2);                                              % �������������������
Img = Img(1:Na-Za,Ntau+1:Ntau+Nr-Zr);                                       % �ü�ͼ����Ч����
Img = Img/max(max(Img));
Img = 20*log10(Img+eps);
Img(Img<-50) = -50;
Img = uint8((Img+50)/50*255);

figure,imagesc(Img);axis image;set(gcf,'Color','w');
figure,imshow(Img);

imwrite(Img,'SAR_RDA_2.bmp','bmp');
