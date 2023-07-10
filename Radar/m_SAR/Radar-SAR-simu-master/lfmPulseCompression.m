%% 
%    ���Ե�Ƶ�źŵ�����ѹ��
%    ���ߣ�Alex_Zikun
% 
%    ���ܣ������Ե�Ƶ�źŽ��з��棬�����ʱƵ��������Ϣ����ģ��ز��źţ�
%    �����������ѹ���ͼӴ�����
% 
%    ʵ���¼��
%     1.���Ե�Ƶ�ź�ʱ����硢��λ��ʵ�����鲿
%     2.���Ե�Ƶ�ź�Ƶ�׷�Ƶ����Ƶ���ԣ�ʵ�����鲿
%     3.����Ŀ��ز���ʱ���Ƶ����
%     4.�ź�ͨ��ƥ���˲�����������������ѹ������
%     5.��Hamming����������ѹ���������
%%  �������� 
    clc;clear all;close all;

    T = 10e-6; % LFM����/���� 10us
    B = 60e6; % LFM���� 60Mhz
    fs = 100e6; % ������ 100MHz
    K = B/T;
%%  ģ�ⷢ���ź�
    n = round(15*T*fs);
    t = linspace(-10*T, 10*T,n);

    lfmT = rectpuls(t,T).*exp(1j*pi*K*t.^2);
    lfmF = fftshift(fft(fftshift(lfmT)));
    f = linspace(-fs,fs,n);

    %% ʱ���ͼ
        figure();
        plot(diff(phase(lfmT)));
        title('LFM�źŵ�ʱ��-Ƶ�ʱ仯����ͼ');
        xlabel('ʱ��');
        ylabel('Ƶ��');
        xlim([7200,7800])
    % ����
        figure();
        subplot(2,2,1);
        plot(t,abs(lfmT));
        title('LFM�ź�ʱ�����');
        xlabel('t/s');
        ylabel('����');
        xlim([-1e-5,1e-5])
        ylim([-0.5,1.5])
    % ��λ
        subplot(2,2,2);
        plot(t,phase(lfmT));
        title('LFM�ź�ʱ����λ');
        xlabel('t/s');
        ylabel('��λ');
        xlim([-5e-6,5e-6])
    % ʵ��
        subplot(2,2,3);
        plot(t,real(lfmT));
        title('LFM�ź�ʱ��ʵ��');
        xlabel('t/s');
        ylabel('����');
        xlim([-1.5e-6,1.5e-6]);
        ylim([-1,1]);
    % �鲿
        subplot(2,2,4);
        plot(t,imag(lfmT));
        title('LFM�ź�ʱ���鲿');
        xlabel('t/s');
        ylabel('����');
        xlim([-1.5e-6,1.5e-6]);
        ylim([-1,1]);
    %% Ƶ���ͼ
        figure();
        subplot(2,2,1);
        plot(f,abs(lfmF));
        title('LFM�źŷ�Ƶ����');
        xlabel('Hz');
        ylabel('����');
        
        subplot(2,2,2);
        plot(unwrap(angle(lfmF)));
        title('LFM�ź���Ƶ����');
        xlabel('Hz');
        ylabel('��λ');
        
        subplot(2,2,3);
        plot(f,real(lfmF));
        title('LFM�ź�Ƶ��ʵ��');
        xlabel('Hz');
        ylabel('����');    
        xlim([-3e7,3e7]);
        
        subplot(2,2,4);
        plot(f,imag(lfmF));
        title('LFM�ź�Ƶ���鲿');
        xlabel('Hz');
        ylabel('����');    
        xlim([-3e7,3e7]);
        
        
    
%%  ģ��ز��ź�
% �ӳ�Ϊ50us��51us�������ź�( 5000���5100��,t��4000��ʼ�洢 )
    %�ӳ�
    t1=50e-6;
    t2=51e-6;
    
    %����ʵ���ź�ʱ���0��ʼ,ʱ�������¶���
    echo1=rectpuls((t-t1),T).*exp(1j*pi*K*(t-t1).^2);
    echo2=rectpuls((t-t2),T).*exp(1j*pi*K*(t-t2).^2);
    echo=echo1+echo2;

     figure();
        subplot(2,2,1)
        plot(t,abs(echo1),'r');
        hold on;
        plot(t,abs(echo2),'b');
        title('�����ز��ź�');
        xlabel('t/s');
        ylabel('����');
        xlim([3.5e-5,7e-5])
        ylim([0,1.5])
        
        subplot(2,2,2)
        plot(t,real(echo));
        title('�ز��ź�ʱ��ʵ��');
        xlabel('t/s');
        ylabel('����');
        xlim([4.9e-5 5.2e-5])
        
        subplot(2,2,3)
        plot(f,fftshift(abs(fft(echo))));
        title('�ز��źŷ�Ƶ����');
        xlabel('Hz');
        ylabel('����');
        
        subplot(2,2,4)
        plot(t,imag(echo));
        title('�ز��ź�ʱ���鲿');
        xlabel('t/s');
        ylabel('����');
        xlim([4.9e-5 5.2e-5])
 
    lfmT = rectpuls(t,T).*exp(1j*pi*K*t.^2);
    lfmF = fftshift(fft(fftshift(lfmT)));
    f = linspace(-fs,fs,n);
    
%%  ����ѹ��(ƥ���˲���
% ����1��
% ���źű䵽Ƶ�� ��2048���FFT)[-fs/2,fs/2]
% Ƶ����� H(w)  =   *S(w)
% �渵��Ҷ�任
% ����2��
% פ����λԭ���ô��ݺ���

% ������÷���1
    %�ز��źŵ�Ƶ����ʽ
    echo_F=fftshift(fft(echo));
    %�ز��źŵ�ƥ���˲���
    Hf=fftshift(fft(conj(lfmT)));
    %��ѹ���
    Pc_F=echo_F.*Hf;
    %��ѹʱ����
    Pc_T=ifftshift(ifft(Pc_F));
    
%��Hamming�����Ƹ���
    %����������
    Hm = [zeros(1,2300) hamming(9900)' zeros(1,2800)];
    %Ƶ��Ӵ�
    Pcw_F = Hm.*Pc_F;
    Pcw_T=ifftshift(ifft(Pcw_F));
    
    figure();
    subplot(2,2,1)
    plot(t,abs(Pc_T));
    title('����ѹ�����ʱ����');
    xlim([4.5e-5 5.5e-5])
    
    subplot(2,2,2)
    plot(f,abs(Pc_F));
    title('����ѹ�����Ƶ��');
    
    subplot(2,2,3)
    plot(f,abs(Pcw_T));
    title('��ѹ�Ӵ����ʱ����');
     xlim([4.5e7 5.5e7])
    
    subplot(2,2,4)
    plot(f,abs(Pcw_F));
    title('��ѹ�Ӵ����Ƶ��');
 