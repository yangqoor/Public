% SAR_Figure_5_16
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
Kr_pos = Kr;                                                                % �����Ƶ��
Kr_neg = -Kr;                                                               % �����Ƶ��
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
S0_pos = zeros(Na,Nr);
S0_neg = zeros(Na,Nr);
for k = 1:Ntarget
    R = sqrt(Ptarget(k,1)^2+(V*eta_m-Ptarget(k,1)*tan(theta)-Ptarget(k,2)).^2);         % ��Ŀ��б�����
    Wr = abs(tau_m-2*R/C)<Tr/2;                                                         % ���δ�����
    Wa = sinc(0.886*atan((V*eta_m-Ptarget(k,2))/Ptarget(k,1))/thetaBW).^2;              % ˫�̲�������ͼ P91(4.27) (4.28)
    S0_pos = S0_pos+Wr.*Wa.*exp(-1i*4*pi*f0*R/C).*exp(1i*pi*Kr_pos*(tau_m-2*R/C).^2);   % ���ɻز��źž��� P156 (6.1)
    S0_neg = S0_neg+Wr.*Wa.*exp(-1i*4*pi*f0*R/C).*exp(1i*pi*Kr_neg*(tau_m-2*R/C).^2);   % ���ɻز��źž��� P156 (6.1)
end

figure,set(gcf,'Color','w');colormap jet;
subplot(1,3,1),imagesc(abs(S0_pos));axis image
title('��a������');xlabel('�����򣨲����㣩');ylabel('��λ�򣨲����㣩');
subplot(1,3,2),imagesc(angle(S0_pos));axis image
title('��b����λ����ɨ��');xlabel('�����򣨲����㣩');
subplot(1,3,3),imagesc(angle(S0_neg));axis image
title('��c����λ����ɨ��');xlabel('�����򣨲����㣩');
