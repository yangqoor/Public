% RADARSAT-1�����ݴ���֮wKA����1
% wKA�ľ�ȷʵ��

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
data = cat(2,data,zeros(Na,Zr));                                            % ��������
data = cat(1,zeros(Za,Nr+Zr),data);                                         % ��λ����
Na = Na+Za;
Nr = Nr+Zr;

figure,imagesc(abs(data));axis image;set(gcf,'Color','w');
title('ʱ�򣺲�����ԭʼ�źŷ���');
xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');

%% ʱ���ᡢƵ��������
tau = t0+(0:Nr-1)*dtau;                                                     % ������ʱ����
ftau = ((0:Nr-1)-Nr/2)/Nr*Fr;                                               % ������Ƶ����
eta = ((0:Na-1)-Na/2)*deta;                                                 % ��λ��ʱ����
feta = fc+((0:Na-1)-Na/2)/Na*Fa;                                            % ��λ��Ƶ����

%% ���뵽��λ�����������
S0 = data.*exp(-1i*2*pi*fc*(eta'*ones(1,Nr)));                              % ������������Ƶ������
clear data

%% �ο��������
Sff = fftshift(fft2(fftshift(S0)));                                         % ��άFFT
clear S0
WindowR = ones(Na,1)*kaiser(Nr,2.5)';                                       % ���봰
WindowA = kaiser(Na,2.5)*ones(1,Nr);                                        % ��λ��
Sff = Sff.*WindowR.*WindowA;                                                % �Ӵ�
clear WindowR WindowA
Hrfm = exp(1i*pi*(4*Rref/C*sqrt((f0+ones(Na,1)*ftau).^2-(C*(feta'*ones(1,Nr))/V/2).^2)+(ones(Na,1)*ftau).^2/Kr)); % ����ο�������ʽ8.3
S1 = Sff.*Hrfm;                                                             % �ο�������ˣ�һ��ѹ������ʽ8.1
clear Sff Hrfm

figure,imagesc(abs(S1));axis image;set(gcf,'Color','w');
title('��άƵ�򣺲ο�������˺���źŷ���');
xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');

%% Stolt��ֵ
% Ƶ����ӳ��
fnew_m = sqrt((f0+ones(Na,1)*ftau).^2-(C*(feta'*ones(1,Nr))/V/2).^2)-f0;    % �µ�Ƶ�ʾ���ʽ8.5
fmin = min(min(fnew_m));                                                    % Ƶ����Сֵ
fmax = max(max(fnew_m));                                                    % Ƶ�����ֵ
fnew_m = ones(Na,1)*linspace(fmin,fmax,Nr);                                 % �����µ�Ƶ�ʾ���
fold_m = sqrt((f0+fnew_m).^2+(C*(feta'*ones(1,Nr))/V/2).^2)-f0;             % ���µ�Ƶ�ʣ�����ɵ�Ƶ��
clear fnew_m
% ��ֵ
Sstolt = zeros(Na,Nr);                                                      % �½����󣬴�Ų�ֵ�������
h = waitbar(0,'Stolt��ֵ');
tic
for ii = 1:Na
    for jj = 1:Nr
        Delta = (fold_m(ii,jj)-ftau(jj))/(Fr/Nr);                           % �������Ƶ�ʲ������
        IntNum = ceil(Delta);                                               % Ƶ�ʲ�����ȡ��
        kk = jj+IntNum;                                                     % ��ԭ�����е�����
        if(5<=kk && kk<=Nr-3)                                               % �߽��޶�
            DecNum = IntNum-Delta;                                          % Ƶ�ʲ��С������
            SincVal = sinc(DecNum-4:1:DecNum+3)';                           % ���ɲ�ֵ��
            Sstolt(ii,jj) = S1(ii,kk-4:kk+3)*SincVal;                       % ��ֵ
        end
    end
    waitbar(ii/Na);
end
toc
close(h);
clear S1 fold_m

%% �任��ͼ����
Stt = ifftshift(ifft2(ifftshift(Sstolt)));                                  % ��άIFFT
% clear Sstolt

%% ����ͼ��
Img = flipud(abs(Stt));                                                     % ���·�תͼ��
Img = Img(1:Na-Za,1:Nr-Zr);                                                 % �ü�ͼ����Ч����
Img = Img/max(max(Img));
Img = 20*log10(Img+eps);
Img(Img<-50) = -50;
Img = uint8((Img+50)/50*255);

figure,imagesc(Img);axis image;set(gcf,'Color','w');
figure,imshow(Img);
imwrite(Img,'SAR_wKA_1.bmp','bmp');
