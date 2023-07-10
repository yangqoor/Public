function [I1, Q1] = maichongyasuo(I, Q, h)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��������·�źŽ�������ѹ��
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [M, N] = size(I);
    K = M / 10;
    f0 = 3 * 10^7;
    fs = 3 * f0;
    Tr = 600 / f0;
    mt2 = floor(3 * Tr * fs / 10);
    mt4 = floor(3 * Tr * fs / 5);
    i1 = I(mt2 + 1:mt2 + K, 1:N);
    q1 = Q(mt2 + 1:mt2 + K, 1:N);

    for i = 1:N
        S1(1:K, i) = fft(i1(1:K, i));
        S2(1:K, i) = fft(q1(1:K, i));
        w_ham = (hamming(K));
        h1 = h .* w_ham';
        H1 = fft(h);
        s(1:K, i) = (S1(1:K, i) + j * S2(1:K, i)) .* H1';
        S3(1:K, i) = ifft(s(1:K, i));
    end

    i2 = I(mt4 + 1:mt4 + K, 1:N);
    q2 = Q(mt4 + 1:mt4 + K, 1:N);

    for i = 1:N
        P1(1:K, i) = fft(i2(1:K, i));
        P2(1:K, i) = fft(q2(1:K, i));
        w_ham = (hamming(K));
        h1 = h .* w_ham';
        H1 = fft(h);
        p(1:K, i) = (P1(1:K, i) + j * P2(1:K, i)) .* H1';
        P3(1:K, i) = ifft(p(1:K, i));
    end

    I1 = [I(1:mt2, 1:N)', real(S3)', I(mt2 + K + 1:mt4, 1:N)', real(P3)', I(mt4 + K + 1:M, 1:N)']';
    Q1 = [I(1:mt2, 1:N)', imag(S3)', I(mt2 + K + 1:mt4, 1:N)', imag(P3)', I(mt4 + K + 1:M, 1:N)']';
    w1 = I1(:)';
    w2 = Q1(:)';
    w3 = sqrt(w1.^2 + w2.^2);
    i = 0:N * M - 1;
    subplot(3, 1, 1);
    plot(i, w1), title('I·�ź�');
    subplot(3, 1, 2);
    plot(i, w2), title('Q·�ź�');
    subplot(3, 1, 3);
    plot(i, w3), title('��·�ϳ�һ·');
