function [I, Q] = xiangganjianbo(s, fs, f0, f1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��λ��ɼ첨
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [M, N] = size(s);
    i = 0:M - 1;
    z1 = cos(2 * pi * f0 * i / (3 * fs));
    z2 = sin(2 * pi * f0 * i / (3 * fs));
    y1 = zeros(M, N);
    y2 = zeros(M, N);

    for i = 1:N
        y1(1:M, i) = (z1 .* s(1:M, i)')';
        y2(1:M, i) = (z2 .* s(1:M, i)')';
    end

    wt1 = 2 * pi * (4 * f1) / (3 * fs); %wt1=4pi/45
    wt2 = 2 * pi * (7 * f1) / (3 * fs); %wt2=7pi/45
    th = wt2 - wt1;
    M1 = ceil(6.6 * pi / th) + 1; %M1=70
    %n=[0:M1-1];
    wt3 = (wt1 + wt2) / 2; %wt3=11pi/90
    hd = wide(wt3, M1);
    w = (hamming(M1))';
    h = hd .* w;
    L = length(h);
    z1 = zeros(M + L - 1, N);
    z2 = zeros(M + L - 1, N);
    I = zeros(M, N);
    Q = zeros(M, N);
    K = ceil(L / 2);

    for i = 1:N

        for j = 1:10
            z1(1 + (j - 1) * M / 10:j * M / 10 + L - 1, i) = conv(h, y1(1 + (j - 1) * M / 10:j * M / 10, i)')';
            z2(1 + (j - 1) * M / 10:j * M / 10 + L - 1, i) = conv(h, y2(1 + (j - 1) * M / 10:j * M / 10, i)')';
            I(1 + (j - 1) * M / 10:j * M / 10, i) = z1(1 + (j - 1) * M / 10 + K:j * M / 10 + K, i);
            Q(1 + (j - 1) * M / 10:j * M / 10, i) = z2(1 + (j - 1) * M / 10 + K:j * M / 10 + K, i);
        end

    end

    w1 = I(:)';
    w2 = Q(:)';
    subplot(4, 1, 1);
    j = 0:length(w1) - 1;
    plot(j, w1), title('I·�ź�');
    subplot(4, 1, 2);
    plot(j, w2), title('Q·�ź�');
    subplot(4, 1, 3);
    w = w1 + i * w2;
    plotpu(w), title('Ƶ��');
    subplot(4, 1, 4);
    plotpu(h), title('��Ƶ����');
