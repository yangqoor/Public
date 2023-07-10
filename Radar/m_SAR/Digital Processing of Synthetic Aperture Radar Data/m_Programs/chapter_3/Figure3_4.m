clc
clear
close all

% ��������
TBP = 100;             % ʱ������
T = 10e-6;             % �������ʱ��
alpha_os = [1.4,1.2,1.0,0.8];             % ��������

% G = figure;
H = figure;
for i=1:length(alpha_os)
    % ��������
    B = TBP/T;             % �źŴ���
    K = B/T;               % ���Ե�ƵƵ��
    F = alpha_os(i)*B;     % ����Ƶ��
    N = 2*ceil(F*T/2);     % ��������
    dt = T/N;              % ����ʱ����
    df = F/N;              % ����Ƶ�ʼ��
    % ��������
    t = -T/2:dt:T/2-dt;    % ʱ�����
    f = -F/2:df:F/2-df;    % Ƶ�ʱ���
    f_zero = -F/2:F/(2*N):F/2-F/(2*N);    % ������Ƶ�ʱ���
    % �źű��
    st = exp(1j*pi*K*t.^2);               % Chirp�źŸ������ʽ
    Sf1 = fft(fftshift(st));              % Chirp�ź�Ƶ�ױ��ʽ
    st_zero = [st,zeros(1,N)];            % Chirp�źŲ�����ʽ
    Sf2 = fft(fftshift(st_zero));         % Chirp�źŲ�����Ƶ�ױ��ʽ
%     % ��ͼ
%     figure(G);
%     subplot(4,2,2*i-1),plot(t*1e+6,real(st))
%     axis([-5 5,-1.2 1.2])
%     if(i==1)
%         title('�ź�ʵ��')
%     end
%     if(i==4)
%         xlabel('ʱ��(\mus)')
%     end
%     
%     % n1 = 0:1:N-1;
%     % subplot(4,2,2*i),plot(n1,abs(Sf1))
%     % axis([0 140,0 17])
%     
%     subplot(4,2,2*i),plot(f*1e-6,abs(Sf1))
%     axis([-4 4,0 22])
%     if(i==1)
%         title('Ƶ�׷���')
%     end
%     if(i==4)
%         xlabel('Ƶ�ʵ�Ԫ(MHz)')
%     end
%     text(2.7,18,['\alpha_{os}= ',num2str(alpha_os(i))],'HorizontalAlignment','center')
    
    % ��ͼ
    figure(H);
    subplot(4,2,2*i-1),plot(t*1e+6,real(st))
    axis([-5 5,-1.2 1.2])
    if(i==1)
        title('�ź�ʵ��')
    end
    if(i==4)
        xlabel('ʱ��(\mus)')
    end
    
    % n2 = 0:1:2*N-1;
    % subplot(4,2,2*i),plot(n2,abs(Sf2))
    % axis([0 280,0 17])
    
    subplot(4,2,2*i),plot(f_zero*1e-6,abs(Sf2))
    axis([-4 4,0 22])
    if(i==1)
        title('Ƶ�׷���')
    end
    if(i==4)
        xlabel('Ƶ�ʵ�Ԫ(MHz)')
    end
    text(2.7,18,['\alpha_{os}= ',num2str(alpha_os(i))],'HorizontalAlignment','center')
end
% figure(G);suptitle('ͼ3.4 ��������\alpha_{os}��Ƶ���������������϶')
figure(H);suptitle('ͼ3.4 ��������\alpha_{os}��Ƶ���������������϶')