function y = gaussianpu(x)
    %��������Ϊn�ĸ�˹��������������Ϊn��������Ϊ��˹�͵ĸ�˹�������
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    N = 0:20;
    f = 20;
    T = 1/256;
    c = 2 * f * T * sqrt(pi) * exp(-4 * f^2 * pi^2 * T^2 * N.^2);
    n = length(x);
    y = zeros(1, n);

    for k = 1:n

        for i = 20:-1:0

            if ((k - i) <= 0)
                continue;
            else
                y(k) = y(k) + c(21 - i) * x(k - i);
            end

        end

        for i = 20:40

            if ((k - i) <= 0)
                continue;
            else
                y(k) = y(k) + c(i - 19) * x(k - i);
            end

        end

    end

    y = 0.5 * y;
