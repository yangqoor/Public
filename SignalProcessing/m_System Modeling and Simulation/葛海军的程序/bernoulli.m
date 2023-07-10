function y = bernoulli(p, n)
    %����������Ϊn�ı�Ŭ���ֲ�,����p����(0-1)֮�䡣
    %-----------------------
    %
    u = junyun(n);
    y = zeros(1, n);

    for i = 1:n

        if (u(i) <= p)
            y(i) = 1;
        else
            y(i) = 0;
        end

    end
