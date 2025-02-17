function y = weibuerpu(a, b, n)
    %由数据量为n的高斯白噪声产生向量为n，功率谱为高斯型的韦布尔分布的随机向量
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    [z1, z2] = gaussian(n);
    z1 = 5 * z1;
    z2 = 5 * z2;
    y1 = sqrt(b^a / 2) * z1;
    y2 = sqrt(b^a / 2) * z2;
    x1 = gaussianpu(y1);
    x2 = gaussianpu(y2);
    x1 = sqrt(b^a / 2) * x1;
    x2 = sqrt(b^a / 2) * x2;
    y = x1.^2 + x2.^2;
    b = canshu(y);
    y = y - b(1);
    %y=conv(y,y);
    %y=fft(y);
    %y=abs(y);
    %i=1:2*n-1;
    %plot(i,y)
    %plotpu(y)
