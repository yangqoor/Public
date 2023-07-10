function [y1, y2] = gaussian(n)
    %����������Ϊn�������໥������˹�ֲ�y1��y2
    %---------------------------------------
    %
    k = 1;
    y1 = zeros(1, n);
    y2 = zeros(1, n);

    while (k <= n)
        u1 = junyun(1);
        u2 = junyun(1);
        v1 = 2 * u1 - 1;
        v2 = 2 * u2 - 1;
        s = v1^2 + v2^2;

        if (s >= 1)
            continue;
        elseif (s == 0)
            k = k + 1;
        else
            y1(k) = v1 * sqrt(-2 * log(s) / s);
            y2(k) = v2 * sqrt(-2 * log(s) / s);
            k = k + 1;
        end

    end
