function y = zhishu(m, n)
    %ָ���ֲ�,m��ʾָ���ֲ��Ĳ���,m����Ϊ0.n��ʾ������,nһ��Ҫ����1024
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x = junyun(n);

    for i = 1; n

        if (x(i) == 0)
            x(i) = 0.0001;
        else
            continue;
        end

    end

    u = log(x);
    y =- (1 / m) * u;
