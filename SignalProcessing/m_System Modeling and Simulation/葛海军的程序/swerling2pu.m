function y = swerling2pu(n)
    %��������Ϊn�ĸ�˹��������������Ϊn��������Ϊ��˹�͵�˹ά��II���������
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    r = 6;
    [z1, z2] = gaussian(n);
    x1 = gaussianpu(z1);
    x2 = gaussianpu(z2);
    y = x1.^2 + x2.^2;
    y = r * y;
    b = canshu(y);
    y = y - b(1); %ȥ��ֱ������
    %y=conv(y,y);
    %y=fft(y);
    %y=abs(y);
    %i=1:2*n-1;
    %plot(i,y)
    %plotpu(y)
