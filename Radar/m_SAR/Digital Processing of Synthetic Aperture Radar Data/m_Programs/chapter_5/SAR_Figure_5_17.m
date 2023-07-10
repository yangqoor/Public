% SAR_Figure_5_17
% 2016.10.13

close all;clear all;clc;

%% ��������
% �״�����
C = 3e8;                                                                    % ����
f0 = 5.3e9;                                                                 % �״﹤��Ƶ��
lambda = C/f0;                                                              % ��������
La = 3.3;
theta = 0;                                                                  % ����б�ӽ�
theta = theta/180*pi;
% ƽ̨����                           
V = 150;                                                                    % �״���Ч�ٶ�
Rc = 20e3;                                                                  % ������б��
R0 = Rc*cos(theta);                                                         % ���б��
% ����������
Tr = 25e-6;                                                                 % ��������ʱ��
Kr = 0.25e12;                                                               % �����Ƶ��
Br = Kr*Tr;
alphaR = 1.2;                                                               % �������������
Fr = alphaR*Br;                                                             % ���������Ƶ��
dtau = 1/Fr;                                                                % ���������ʱ����
Nr = 256;                                                                   % ��������
% ��λ������
Bdop = 0.886*2*V*cos(theta)/La;                                             % �����մ���
alphaA = 1.3;                                                               % ��λ���������
Fa = alphaA*Bdop;                                                           % ��λ�����Ƶ��
deta = 1/Fa;                                                                % ��λ�����ʱ����
Na = 256;                                                                   % ��λ����
fc = 2*V*sin(theta)/lambda;                                                 % ����������Ƶ��
thetaBW = 0.886*lambda/La;                                                  % ��λ�������

%% ��Ŀ������
Ntarget = 1;
Ptarget = [R0,0];                                                           % ���������꣬��λ������

%% ʱ���ᡢƵ��������
tau = linspace(-Nr/2,Nr/2-1,Nr)*dtau+2*Rc/C;                                % ������ʱ����
eta = linspace(-Na/2,Na/2-1,Na)*deta;                                       % ��λ��ʱ����
tau_m = ones(Na,1)*tau;                                                     % ������ʱ�������
eta_m = eta'*ones(1,Nr);                                                    % ��λ��ʱ�������

%% ���ɻز��źž���
S0 = zeros(Na,Nr);
for k = 1:Ntarget
    R = sqrt(Ptarget(k,1)^2+(V*eta_m-Ptarget(k,1)*tan(theta)-Ptarget(k,2)).^2);         % ��Ŀ��б�����
    Wr = abs(tau_m-2*R/C)<Tr/2;                                                         % ���δ�����
    Wa = sinc(0.886*atan((V*eta_m-Ptarget(k,2))/Ptarget(k,1))/thetaBW).^2;              % ˫�̲�������ͼ P91(4.27) (4.28)
    S0 = S0+Wr.*Wa.*exp(-1i*4*pi*f0*R/C).*exp(1i*pi*Kr*(tau_m-2*R/C).^2);   % ���ɻز��źž��� P156 (6.1)
end

Srd = fft(S0,[],1);
Sff = fft(Srd,[],2);

figure,set(gcf,'Color','w');colormap jet;
subplot(2,2,1),imagesc(abs(Srd));axis image
title('��a��RD��Ƶ�׷���');xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');
subplot(2,2,2),imagesc(angle(Srd));axis image
title('��b��RD��Ƶ����λ');xlabel('�����򣨲����㣩');
subplot(2,2,3),imagesc(abs(Sff));axis image
title('��c����άƵ�׷���');xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');
subplot(2,2,4),imagesc(angle(Sff));axis image
title('��d����άƵ����λ');xlabel('�����򣨲����㣩');
