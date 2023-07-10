function [t, s, g, f0, fs, f1] = huibo
    %����Ŀ��ز��ź�x,ϵͳ����y�������Ӳ�z�Լ��ز�p
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    f0 = 3 * 10^7;                 %�����ź�Ƶ��
    w = 0;                         %�����źų�ʼ��λ
    c = 3 * 10^8;                  %����
    l = c / f0;                    %�״��źŲ���(�ز�����)
    R = 40000;                     %Ŀ�귶Χ
    Vd = 200;                      %�״���Ŀ��֮��ľ����ٶ�
    fd = 2 * Vd / l;               %������Ƶ��
    Tr = 600 / f0;                 %�����ظ�����
    N = 10;                        %�״����崮����
    f1 = f0 / 5;                   %��Ƶ�����Ƿ����ź�Ƶ�ʵ�1/5
    k = 10 * f1 / Tr;
    fs = 3 * f0;                   %�������Ƶ��
    Ts = 1 / fs;
    %Tt=2*R/c;
    Btar = 4 * pi * R / l;         %
    M = floor(Tr * fs);            %һ�������ظ������ڵĲ�������M=600
    mt1 = floor(2 * Tr * fs / 5);  %mt1=720
    mt2 = floor(3 * Tr * fs / 10); %mt2=540
    mt3 = floor(7 * Tr * fs / 10); %mt3=1260
    mt4 = floor(3 * Tr * fs / 5);  %mt4=1080
    mt5 = mt1 - mt2;               %mt5=180
    Vgain = 6;
    s = zeros(M, N);               %�ز��������

    for m = 1:M

        for n = 1:N
            v(m, n) = (u(mt1 - m) - u(mt2 - m)) * Vgain * cos(2 * pi * f0 * (m - mt2) * Ts + 2 * pi * k * Ts * (m - mt2) / 2 * (m - mt2) * Ts + 2 * pi * fd * n * Tr);
            g(m, n) = (u(mt3 - m) - u(mt4 - m)) * Vgain * cos(2 * pi * (f0 * (m - mt4) * Ts + k * Ts * (m - mt4) / 2 * (m - mt4) * Ts));
            %u(t)�Ƿ����źŰ���
        end

    end

    for i = 1:M / 10
        t(i) = Vgain * cos(2 * pi * (k * Ts * (M / 10 - i) / 2 * (M / 10 - i) * Ts));
    end

    for n = 1:N
        y(1:M, n) = gaussian(M)'; %ϵͳ�������Ӹ�˹�ֲ�
    end

    for n = 1:N
        z(1:M, n) = swerling2pu(M)'; %�����Ӳ�����swerling2�ͷֲ�
    end

    s = v + g + y + z;
    %s=v+g;
    [m, n] = size(s);
    x = zeros(1, m * n);
    q = zeros(1, m * n);
    x = s(:)';
    q = g(:)';
    p = x;
    i = 0:length(p) - 1;
    subplot(2, 1, 1);
    plot(i, x), title('Ŀ��ز��ź�'); %Ŀ��ز��ź�x
    subplot(2, 1, 2);
    l = canshu(x);
    b = x - l(1);
    plotpu(b), title('Ŀ��ز�Ƶ��');
