function y = junyun(n)
    %0-1�ľ��ȷֲ���n������������һ��Ҫ����1024
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    y = ones(1, n);
    x = ones(1, n);
    m = 100000;
    x0 = mod(ceil(m * rand(1, 1)), m);
    x0 = floor(x0 / 2);
    x0 = 2 * x0 + 1;
    u = 11;
    x(1) = x0;

    for i = 1:n - 1
        x(i + 1) = u * x(i) + 0;
        x(i + 1) = mod(x(i + 1), m);
        x(i) = x(i) / m;
    end

    %x(n)��λ��
    x(n) = x(n) / m;
    y = x;
