function y = correlation(x)
    %����x������غ���
    %---------------
    %
    n = length(x);

    for i = 1:n
        x1(i) = x(n + 1 - i);
    end

    y = conv(x, x1);
