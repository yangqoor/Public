function y = kexipu(m, n)
    %��������Ϊn�ĸ�˹��������������Ϊn��������Ϊ�����׵ĸ�˹�������
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    wc = 2 * pi * 256;
    T0 = 1 / (256 * m);
    x = gaussian(n);
    y = zeros(1, n);
    y(1) = wc * T0 * x(1);

    for i = 2:n
        y(i) = wc * T0 * x(i) + exp(-wc * T0) * y(i - 1);
    end

    b = canshu(y);
    %y=y-b(1);���������� %ȥ��ֱ������������
    y = conv(y, y);
    y = fft(y);
    y = abs(y);
    i = 1:2 * n - 1;
    plot(i, y)
