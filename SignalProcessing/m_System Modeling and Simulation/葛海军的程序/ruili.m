function y = ruili(m, n)
    %�����ֲ�,m�������ֲ��Ĳ���,n����������,nһ��Ҫ����1024
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x = junyun(n);

    for i = 1:n

        if (x(i) == 0)
            x(i) = 0.0001;
        else
            continue;
        end

    end

    u = (-2) * log(x);
    y = m * sqrt(u);
