function plotpu(x)
    %���������Ĺ������ܶȺ���Ƶ���ͼ�Ρ�
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %y=gaussianpu(x);
    %r=correlation(y);
    w = fft(x);
    w = abs(w);
    v = 2 * pi / length(w);
    i = 0:v:(2 * pi - v);
    plot(i, w);
