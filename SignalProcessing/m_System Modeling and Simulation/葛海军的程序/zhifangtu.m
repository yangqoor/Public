function zhifangtu(x, m)
    %�����ݵ�ֱ��ͼ,x��ʾҪ���������,m��ʾ��Ҫ��������
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    a = min(x);
    b = max(x);
    l = length(x);
    h = (b - a) / m;
    %����x
    x = x / h;
    x = ceil(x);
    w = zeros(1, m);

    for i = 1:l

        for j = 1:m

            if (x(i) == j)
                %x(i)����j�������ϣ���w(j)��1
                w(j) = w(j) + 1;
            else
                continue
            end

        end

    end

    w = w / (h * l);
    z = a:h:(b - h);
    bar(z, w);
    title('ֱ��ͼ')
