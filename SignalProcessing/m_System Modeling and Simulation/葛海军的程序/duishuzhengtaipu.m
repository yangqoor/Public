function y = duishuzhengtaipu(a, b, n)
    %��������Ϊn�ĸ�˹��������������Ϊn��������Ϊ��˹�͵Ķ�����̬�������
    %a��ʾ��׼����,b��ʾ��ֵ
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    z1 = gaussian(n);
    x = gaussianpu(z1);
    y = a * x;
    y = exp(y);
    y = b * y;
    b = canshu(y);
    y = y - b(1); %ȥ��ֱ������
    %y=conv(y,y);
    %y=fft(y);
    %y=abs(y);
    %i=1:2*n-1;
    %plot(i,y)
    %plotpu(y)
