% 2016/10/12

clc;
clear;
close all;
% �״�ƽ̨����
C = 3e8;
Fc = 5.3e9;
Vr = 150;
theta_rc = 0 / 180 * pi; %����б�ӽ�
H = 5000;
R0 = 2e4;
Y0 = 1e4;%��������Y��
La = 4;


% ��ʱ�����
Tr = 2.5e-6;
Kr = 20e12;
alpha_Fsr = 1.2;%  �����������

% ��ʱ�����
alpha_Fsa = 1.25;
delta_x = 400;
delta_y = 150;

Targets = [ 0  -100   1
            200 0     2
            0   100   2
           -200 0  1];



