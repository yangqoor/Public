function y = duishuzhengtai(a, b, n)
    %����������̬�ֲ���a,bΪ����ֲ��Ĳ�����nΪ������
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x = gaussian(n);
    u = sqrt(b) * x + a;
    y = exp(u);
