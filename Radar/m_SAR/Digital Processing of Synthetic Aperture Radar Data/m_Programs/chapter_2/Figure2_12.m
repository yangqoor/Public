clc
close all
clear all

N = 100;
beta = [0,1,2,3,4,5,6];

hw = [];
pslr = [];
% tempn = [];

% set(figure,'position',[100,100,1200,600]);
for i = 1:1:7
    % ����kauser��
    A = kaiser(N,beta(i));
    % ����Kaiser��
    % plot(A),hold on
    % ��kaiser�����и���Ҷ�任
    temp = fft(A,2^14);
    temp = 20*log10(abs(temp)./max(abs(temp)));
    % tempn = [tempn,temp];
    % ��ȡkaiser����3dB�������
    [hwn,locleft,locright] = get_hw(temp);
    hw = [hw,hwn];
    % ��ȡKaiser���ķ�ֵ�԰��
    [pslrn] = get_pslr(temp);
    pslr = [pslr,pslrn];
end

% title('ͼ2.11 ��ͬ\betaֵ��Kaiser����״'),xlabel('������'),ylabel('����')
% axis([-11 110,-0.2 1.2])
% grid on

% text('Interpreter','latex','String','$\beta=0.0$','Position',[-9 1.00],'FontSize',16);
% text('Interpreter','latex','String','$\beta=1.0$','Position',[-9 0.80],'FontSize',16);
% text('Interpreter','latex','String','$\beta=2.0$','Position',[-9 0.45],'FontSize',16);
% text('Interpreter','latex','String','$\beta=3.0$','Position',[-9 0.21],'FontSize',16);
% text('Interpreter','latex','String','$\beta=4.0$','Position',[-9 0.10],'FontSize',16);
% text('Interpreter','latex','String','$\beta=5.0$','Position',[-9 0.05],'FontSize',16);
% text('Interpreter','latex','String','$\beta=6.0$','Position',[-9 0.00],'FontSize',16);

% tempn
% tempn(:,1)
% figure,set(figure,'position',[100,100,1200,600]);
% plot(fftshift(tempn))
% title('ͼ2.11 ��ͬ\betaֵ��Kaiser��Ƶ��'),xlabel('������'),ylabel('����/dB')
% axis([5000 11500,-150 10])
% grid on
% set(legend,'Location','NorthEastOutside')
% legend('\beta=0','\beta=1','\beta=2','\beta=3','\beta=4','\beta=5','\beta=6')

% figure,set(figure,'position',[100,100,1200,600]);
% plot(fftshift(tempn(:,1)))
% title('ͼ2.11 \beta=0ʱ��kaiser��Ƶ��'),xlabel('������'),ylabel('����/dB')
% axis([5000 11500,-150 10])
% grid on

% figure,set(figure,'position',[100,100,1200,600]);
% plot(fftshift(tempn(:,7)))
% title('ͼ2.11 \beta=6ʱ��kaiser��Ƶ��'),xlabel('������'),ylabel('����/dB')
% axis([5000 11500,-150 10])
% grid on

set(figure,'position',[100,100,1200,600]);
% 3dB���չ���
% hw
subplot(121),plot((hw./hw(1)-1)*100)
title('(a)3dB���չ���'),xlabel('Kaiser��\beta'),ylabel('չ���')
grid on
% ��ֵ�԰��
% pslr
subplot(122),plot(pslr)
title('(b)��ֵ�԰��'),xlabel('Kaiser��\beta'),ylabel('PSLR/dB')
grid on
suptitle('ͼ2.12 ��ͬKaiser����չ��ͷ�ֵ�԰��')

function [hw,locleft,locright] = get_hw(Af)
    % �ҵ�Af�����λ��
    [~,locmax] = max(Af);
    % �ҵ�locmax�����ӽ�-3dB��λ��
    [~,locleft] = min(abs(Af(1:locmax)+3));
    % �ҵ�locmax�ұ���ӽ�-3dB��λ��
    [~,locright] = min(abs(Af(locmax:end)+3));
    locright = locright + locmax - 1;
    % �õ�3dB�������
    hw = locright-locleft;
end

function [pslr] = get_pslr(Af)
    % �ҵ����е�pesks
    peaks = findpeaks(Af);
    % ��peaks��������
    peaks = sort(peaks,'descend');
    % �õ���һ�԰�
    pslr = peaks(2);
end