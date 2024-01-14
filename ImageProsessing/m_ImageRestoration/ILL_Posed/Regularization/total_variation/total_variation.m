function u = total_variation(u0, IterMax, lambda)
    %% 初始化
    u = u0;
    [M, N] = size(u);
    Energy(IterMax) = 0;
    % 空间离散
    h = 1;

    %% 迭代
    for Iter = 1:IterMax

        for i = 2:M - 1

            for j = 2:N - 1
                % 系数计算
                ux = (u(i + 1, j) - u(i, j)) / h;
                uy = (u(i, j + 1) - u(i, j - 1)) / 2 * h;
                Grad = sqrt(ux * ux + uy * uy);
                % 梯度为0 co1->Inf 可能导致图像变黑
                if Grad ~= 0
                    co1 = 1 ./ Grad;
                else
                    co1 = Grad;
                end

                ux = (u(i, j) - u(i - 1, j)) / h;
                uy = (u(i - 1, j + 1) - u(i - 1, j - 1)) / 2 * h;
                Grad = sqrt(ux * ux + uy * uy);

                if Grad ~= 0
                    co2 = 1 ./ Grad;
                else
                    co2 = Grad;
                end

                ux = (u(i + 1, j) - u(i - 1, j)) / 2 * h;
                uy = (u(i, j + 1) - u(i, j)) / h;
                Grad = sqrt(ux * ux + uy * uy);

                if Grad ~= 0
                    co3 = 1 ./ Grad;
                else
                    co3 = Grad;
                end

                ux = (u(i + 1, j - 1) - u(i - 1, j - 1)) / 2 * h;
                uy = (u(i, j) - u(i, j - 1)) / h;
                Grad = sqrt(ux * ux + uy * uy);

                if Grad ~= 0
                    co4 = 1 ./ Grad;
                else
                    co4 = Grad;
                end

                u(i, j) = (u0(i, j) + (1 / lambda * h * h) * (co1 * u(i + 1, j)...
                +co2 * u(i - 1, j) + co3 * u(i, j + 1) + co4 * u(i, j - 1)))...
                * (1 / (1 + (1 / (lambda * h * h) * (co1 + co2 + co3 + co4))));
            end

        end

        % 边缘条件
        for i = 2:M - 1
            u(i, 1) = u(i, 2); % 第一列的计算等于第二列
            u(i, N) = u(i, N - 1); % 最后一列的计算等于倒数第二列
        end

        for j = 2:N - 1
            u(1, j) = u(2, j);
            u(M, j) = u(M - 1, j); % 同理，第一行和最后一行的计算等于和它相近的行
        end

        u(1, 1) = u(2, 2);
        u(1, N) = u(2, N - 1);
        u(M, 1) = u(M - 1, 2);
        u(M, N) = u(M - 1, N - 1); % 四个角的值也近似与它相近的点

        % 计算每次迭代的离散能量
        en = 0.0; % 设能量初始值为0

        for i = 2:M - 1

            for j = 2:N - 1
                ux = (u(i + 1, j) - u(i, j)) / h;
                uy = (u(i, j + 1) - u(i, j)) / h;
                fid = (u0(i, j) - u(i, j)) * (u0(i, j) - u(i, j));
                en = en + sqrt(ux * ux + uy * uy) + lambda * fid;
            end

        end

        % 计算每次迭代的能量
        Energy(Iter) = en;
    end

    %% 绘图-每次迭代的能量
    figure
    plot(Energy); legend('Energy/Iterations');
