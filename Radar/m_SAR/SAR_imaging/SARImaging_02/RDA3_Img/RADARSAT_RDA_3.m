% RADARSAT-1�����ݴ���֮RDA����SRC3
% ����ʵ�ֶ��ξ���ѹ����RDA

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
deta = 1/Fa;                                                                % ���������ʱ����
% ��������
t0 = 6.5956e-3;                                                             % ��ȡ����ʱ��
R0 = t0*C/2;                                                                % ���б��

%% ��ȡԭʼ����
oldFolder = cd('.\scene01');
load CDdata1.mat
cd(oldFolder);
data=double(data);
[Na,Nr] = size(data);

%% ȷ���ο�����
Rref = (t0+Nr/2*dtau)*C/2;                                                  % �ο�����ѡ�ڳ�����������

%% ����ĩβ����
Za = 800;                                                                   % ��λ������
Zr = ceil(Tr/dtau);                                                         % ����������
data = cat(2,data,zeros(Na,Zr));                                            % ��������(�ұ�)
data = cat(1,zeros(Za,Nr+Zr),data);                                         % ��λ����(�Ϸ�)
Na = Na+Za;%2336
Nr = Nr+Zr;%3398

figure,imagesc(abs(data));axis image;set(gcf,'Color','w');
title('ʱ�򣺲�����ԭʼ�źŷ���');
xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');

%% ʱ���ᡢƵ��������
ftau = ((0:Nr-1)-Nr/2)/Nr*Fr;                                               % ������Ƶ����
eta = ((0:Na-1)-Na/2)*deta;                                                 % ��λ��ʱ����
feta = fc+((0:Na-1)-Na/2)/Na*Fa;                                            % ��λ��Ƶ����

%% ���뵽��λ�����������
S0 = data.*exp(-1i*2*pi*fc*(eta'*ones(1,Nr)));                              % ������������Ƶ������
clear data

%% ��άƵ����ʵ��RC��SRC����ʽ3�ľ���ѹ����
% ��ʽ3�������趨�����Ե�Ƶ���ԣ�ֱ����Ƶ������ƥ���˲���
Sff = fftshift(fft2(fftshift(S0)));
clear S0
WindowR = ones(Na,1)*kaiser(Nr,2.5)';                                       % ���봰
WindowA = kaiser(Na,2.5)*ones(1,Nr);                                        % ��λ��
Sff = Sff.*WindowR.*WindowA;                                                % �Ӵ�
clear WindowR WindowA
D = sqrt(1-(lambda*feta/2/V).^2);                                           % �㶯���ӣ�ʽ6.24
Ksrc = (2*V^2*f0^3*(D'*ones(1,Nr)).^3)./(C*R0*(feta'*ones(1,Nr)).^2);       % SRC�˲�����Ƶ�ʣ�ʽ6.22
Km = Kr./(1-Kr./Ksrc);                                                      % �ϲ��˲�����Ƶ�ʣ�ʽ6.21
clear Ksrc
Hm = exp(1i*pi*((ones(Na,1)*ftau).^2)./Km);                                 % �ϲ��˲�����ʽ6.29
clear Km
S1 = Sff.*Hm;                                                               % RC��SRC
clear Sff Hm
Srd = ifftshift(ifft(ifftshift(S1,2),[],2),2);                              % �任��RD��
clear S1

figure,imagesc(abs(Srd));axis image;set(gcf,'Color','w');
title('RD�򣺾���ѹ������źŷ���');
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
imwrite(Img,'SAR_RDA_3.bmp','bmp');
