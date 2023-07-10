function y = kaifeng(m, n)
    %��������ֲ�������m������ֲ������ɶȣ�n��ʾ�����ĵ�����
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    y = zeros(1, n);

    if (floor(m / 2) == m / 2)

        for i = 1:m / 2
            [x1, x2] = gaussian(n);

            for j = 1:n
                y(j) = x1(j)^2 + x2(j)^2 + y(j);
            end

        end

    else

        for i = 1:floor(m / 2)
            [x1, x2] = gaussian(n);

            for j = 1:n
                y(j) = x1(j)^2 + x2(j)^2 + y(j);
            end

        end

        x = gaussian(n);

        for j = 1:n
            y(j) = y(j) + x(j)^2;
        end

    end
