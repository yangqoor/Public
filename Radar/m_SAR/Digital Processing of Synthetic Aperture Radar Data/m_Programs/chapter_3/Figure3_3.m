clc
clear
close all

% ��������
TBP = [25,50,100,200,400]; % ʱ������
T = 1e-6;                  % �������ʱ��

H = figure;
for i = 1:5
    % ��������
    B = TBP(i)/T;          % �źŴ���
    K = B/T;               % ���Ե�ƵƵ��
    alpha_os = 1.25;       % ��������
    F = alpha_os*B;        % ����Ƶ��
    N = 2*ceil(F*T/2);     % ��������
    dt = T/N;              % ����ʱ����
    df = F/N;              % ����Ƶ�ʼ��
    % ��������
    t = -T/2:dt:T/2-dt;    % ʱ�����
    f = -F/2:df:F/2-df;    % Ƶ�ʱ���
    % �źű��
    st = exp(1j*pi*K*t.^2);               % Chirp�źŸ������ʽ
    Sf = fftshift(fft(fftshift(st)));     % Chirp�ź�Ƶ�ױ��ʽ
    % ��ͼ
    figure(H);
    % Ƶ�׷���
    subplot(5,2,2*i-1)
    plot(f*1e-6,abs(Sf))
    axis([-F*1e-6/2-F*1e-6/100 F*1e-6/2+F*1e-6/100,0 8+6*(i-1)])
    if(i==5)
        xlabel('Ƶ��(MHz)')
    end
    ylabel('����')
    line([-B*1e-6/2,-B*1e-6/2],[0,sqrt(1/K)*1e+6*N],'color','k','linestyle','--')
    line([ B*1e-6/2, B*1e-6/2],[0,sqrt(1/K)*1e+6*N],'color','k','linestyle','--')
    line([-B*1e-6/2, B*1e-6/2],[sqrt(1/K)*1e+6*N,sqrt(1/K)*1e+6*N],'color','k','linestyle','--')
    % Ƶ����λ
    subplot(5,2,2*i)
    plot(f*1e-6,unwrap(angle(Sf))-max(unwrap(angle(Sf)))),hold on
    plot(f*1e-6,(-pi*f.^2/K)-max(-pi*f.^2/K),'k--');
    % set(gca,'YDir','reverse')    % ���������ᷭת
    axis([-F*1e-6/2-F*1e-6/10 F*1e-6/2+F*1e-6/10,-32*2^(i-1) 0])
    if(i==5)
        xlabel('Ƶ��(MHz)')
    end
    ylabel('��λ(����)')
    text(0,-TBP(i)/2,['TBP= ',num2str(TBP(i))],'HorizontalAlignment','center')
end
suptitle('ͼ3.3 ��ͬTBPֵ����ɢ����Ҷ�任Ƶ�ױ仯')