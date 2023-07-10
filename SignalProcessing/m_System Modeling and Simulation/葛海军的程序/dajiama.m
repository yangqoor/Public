function y = dajiama(a, b, n)
    %����٤������ֲ������ݣ�a��bΪ����ֲ��Ĳ�����������Ϊn
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    k = 1;

    if (a < 1)

        while (k <= n)
            x1 = junyun(1);
            x2 = junyun(1);
            y2 = (exp(1) + a) / exp(1) * x2;

            if (y2 > 1)
                p = -log(((exp(1) + a) / exp(1) - y2) / a);

                if (x1 < p^(a - 1))
                    y(k) = p;
                    k = k + 1;
                else
                    continue;
                end

            else
                p = y2^(1 / a);

                if (x1 < exp(-p))
                    y(k) = p;
                    k = k + 1;
                else
                    continue;
                end

            end

        end

    elseif (a >= 1)

        while (k <= n)
            x1 = junyun(1);
            x2 = junyun(1);
            v = (2 * a - 1)^(-0.5) * log(x1 / (1 - x2));
            x = a * exp(v);
            z = x1^2 * x2;
            w = a - log(4) + (a + sqrt(2 * a - 1)) * v - x;

            if (w >= log(z))
                y(k) = x;
                k = k + 1;
            else
                continue;
            end

        end

    end

    y = b * y;
