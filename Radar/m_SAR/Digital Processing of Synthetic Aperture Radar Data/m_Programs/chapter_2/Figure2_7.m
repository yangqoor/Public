clc
close all
clear all

T = 10e-3;
F = 300;
t = 0:T/10000:T-T/10000;

A = sin(2*pi*F*t); % ԭʼ�ź�

% figure
% plot(t,A,'k'),hold on
% title('��ͬ�����ʶ�300Hz�����Ҳ�������˵���������'),xlabel('t','Interpreter','latex'),ylabel('A','Interpreter','latex')
% grid on

% �������ο�˹�ز�������
fs1 = 400;   % ���ò���Ƶ��
dt1 = 1/fs1; % ����������

t1 = 0:dt1:T;

A1 = sin(2*pi*F*t1); % �����ź�

cs1 = spline(t1,A1);
xx1 = linspace(t1(1),t1(end),1000); % ��ֵ��
yy1 = ppval(cs1,xx1); % ��ֵ

% plot(t1,A1,'rp'),hold on
% plot(xx1,yy1,'r'),hold on

% �����ο�˹�ز�������
fs2 = 1600;  % ���ò���Ƶ��
dt2 = 1/fs2; % ����������

t2 = 0:dt2:T;

A2 = sin(2*pi*F*t2);    % �����ź�

cs2 = spline(t2,A2);
xx2 = linspace(t2(1),t2(end),1000);     % ��ֵ��
yy2 = ppval(cs2,xx2);   % ��ֵ

% plot(t2,A2,'bh'),hold on
% plot(xx2,yy2,'b'),hold on

% set(legend,'Location','NorthEastOutside')
% legend('ԭʼ�ź�','','400Hz����','','1600Hz����')

%% ��ͼ
figure
plot(t,A,'k'),hold on
title('��ͬ�����ʶ�300Hz�����Ҳ�������˵���������'),xlabel('t','Interpreter','latex'),ylabel('A','Interpreter','latex')
plot(t1,A1,'rp'),hold on
plot(xx1,yy1,'r'),hold on
plot(t2,A2,'bh'),hold on
plot(xx2,yy2,'b'),hold on
grid on
%% ͼ��
set(legend,'Location','NorthEastOutside')
legend('ԭʼ�ź�','','400Hz����','','1600Hz����')
