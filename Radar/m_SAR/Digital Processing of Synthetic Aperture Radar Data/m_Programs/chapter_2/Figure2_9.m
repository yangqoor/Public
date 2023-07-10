clc
close all
clear all

% LFM�ź� ʵ�ź� s(t) = cos(2*pi*(f0.*t + 0.5*K*t.^2))
% LFM�ź� ���ź� s(t) = exp(1i*2*pi*(f0.*t + 0.5*K*t.^2))

% ��������
T = 1;
B = 150;
K = B/T;

% figure('Name','...','NumberTitle','off')
% figure��������
% set(gca,'XTick',[xmin:���:xmax])
% set(gca,'YTick',[ymin:���:ymax])
% grid on
% set(gca,'Xgrid','off')
% set(gca,'Ygrid','off')
% box off
% legend('lenname1','lenname2'),set(legend,'Location','NorthEastOutside'),set(legend,'Position',[xmin,xmax,ymin.ymax])

set(figure,'position',[100,100,900,800]);

for i = 1:1:5
    
    f0 = -75+(i-1)*100;

    % ԭʼ�ź�
    dt = 1/2000;
    t1 = 0:dt:T-dt;
    
    At = t1+2;
    At = At./max(max(At));  % �źŷ�������
    
    st = exp(1i*2*pi*(f0*t1+0.5*K*t1.^2)).*At;
    
    % ����Ҷ�任
    N1 = 2^20;
    df = 1/dt;
    f1 = -df/2:df/N1:df/2-df/N1;
    
    Sf = fft(st,N1);
    Sf = fftshift(abs(Sf)/max(abs(Sf)));
    
    % �����ź�
    Fs = 400;
    Dt = 1/Fs;
    t2 = 0:Dt:T-Dt;
    
    Bt = t2+2;
    Bt = Bt./max(max(Bt));
    
    st_c = exp(1i*2*pi*(f0*t2+0.5*K*t2.^2)).*Bt;
    
    % ����Ҷ�任
    N2 = 2^20;
    f2 = -Fs/2:Fs/N2:Fs/2-Fs/N2;
    
    Sf_c = fft(st_c,N2);
    Sf_c = fftshift(abs(Sf_c)/max(abs(Sf_c)));
    
    % figure 
    % plot(t1,st,'b')
    % xlabel('t'),ylabel('st')
    %grid on
    
    % figure
    % plot(f1,Sf,'b')
    % xlabel('f'),ylabel('Sf')
    % grid on
    
    % figure
    % plot(f2,Sf_c,'b')
    % xlabel('f'),ylabel('Sf_c')
    % grid on
    
    subplot(5,3,[3*(i-1)+1,3*(i-1)+2]),plot(f1,Sf,'b')
    xlabel('Ƶ��'),ylabel('����')
    axis([-200 600, 0 1])
    grid on
    subplot(5,3,3*i)
    plot(f2,Sf_c,'b')
    xlabel('Ƶ��'),ylabel('����')
    axis([-200 200, 0 1])
    grid on
end

suptitle('ͼ2.8 ���������Ƶ��ƽ��(���ź�)')