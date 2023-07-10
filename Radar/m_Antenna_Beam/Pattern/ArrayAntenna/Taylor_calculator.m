%输入参数：
%d:单元间距d=1/2表示，距离为d=λ/2
%N:为阵元数
%R0dB:为副瓣电平要求
%n__:想控制第几对零点n__
%输出参数：
%x：角度0-180°
%x_i:激励位置
%SxdB：泰勒阵列相对幅度方向图
%In_normal：泰勒归一化激励幅度值In_normal
%调用：[x,x_i,In_normal,SxdB] = Taylor_calculator(0.5,19,6,20);

function [x, x_i, In_normal, SxdB] = Taylor_calculator(d, N, n__, R0dB)

    x = 2:1:178; %角度
    r0 = 10^(R0dB / 20); %副瓣电平要求20lgR0=20dB
    A = (1 / pi) .* acosh(r0); %根据副瓣电平要求r0求A
    n_ = ceil(2 * A^2 + 1/2); %求出n一撇，n_≥2A^2+0.5.

    if n_ < n__;
        n_ = n__;
    end

    %求泰勒方向图函数各个根Xn
    for n = 1:1:n_ - 1;
        Xn(n) = n_ * sqrt((A^2 + (n - 1/2)^2) / (A^2 + (n_ - 1/2)^2));
    end

    %for n=n_:1:N;
    % Xn(:,n) = n;
    %end

    %求泰勒阵列函数阵因子方向图
    Xu = N * d * cos(x .* pi / 180); %Xu=L/λcosθ,L=Nd,d为单元间距，取d=λ/2，x为角度化成弧度，θ=x*(pi/180),有Xu=N/2*cos(x.*pi/180).

    for n = 1:1:n_ - 1;
        Sx0(:, n) = 1 - ((Xu.^2) ./ (Xn(n).^2));
    end

    Sx0_p = prod(Sx0');

    for n = 1:1:n_ - 1;
        Sx1(:, n) = 1 - ((Xu.^2) ./ (n.^2)); %二维数组
    end

    Sx1_p = prod(Sx1');
    Sx = cosh(pi * A) .* (((sin(pi * Xu) .* Sx0_p) ./ ((pi * Xu) .* Sx1_p)));
    Sx_max = max(Sx);
    SxdB = 20 * log10((abs(Sx)) / Sx_max); %归一化方向图
    %figure(1);
    %plot(x,SxdB);
    %title('泰勒线阵相对幅度方向图');

    %求激励
    for i = 1:1:n_ - 1;
        Si(:, i) = factorial(n_ - 1)^2 ./ factorial(n_ - 1 + i) ./ factorial(n_ - 1 - i);

        for n = 1:1:n_ - 1;
            In(:, n) = 1 - (i ./ (Xn(n))).^2;
        end

        In_p(:, i) = prod(In');
    end

    Sian_ = Si .* In_p;

    if mod(N, 2) == 0 % % N为偶数
        m = N / 2; %单元总数为偶数时N=2m，奇数时为N=2m+1

        for n = 1:1:m;

            for i = 1:1:n_ - 1;
                s_cos(:, i) = Sian_(i) .* cos(2 * pi * i * (2 * (n - 1) + 1) / 2 / N);
            end

            In_m(:, n) = 1 + 2 * sum(s_cos');
        end

        for n = 1:1:m;
            In_(:, n) = In_m(m + 1 - n); %给出另一边激励，翻转
        end

        In__ = [In_, In_m];

    elseif mod(N, 2) == 1 % % N为奇数
        m = (N - 1) / 2; %单元总数为偶数时N=2m,奇数时为N=2m+1

        for n = 1:1:m + 1;

            for i = 1:1:n_ - 1;
                s_cos(:, i) = Sian_(i) .* cos(2 * pi * i * (n - 1) / N);
            end

            In_m(:, n) = 1 + 2 * sum(s_cos');
        end

        for n = 1:1:m;
            In_(:, n) = In_m(m + 2 - n); %给出另一边激励，翻转
        end

        In__ = [In_, In_m];
    end

    if mod(N, 2) == 0 % % N为偶数
        m = N / 2; %单元总数为偶数时N=2m，奇数时为N=2m+1
        x_i = (-m + 0.5) * 0.5:0.5:(m - 0.5) * 0.5;
    elseif mod(N, 2) == 1 % % N为奇数
        m = (N - 1) / 2; %单元总数为偶数时N=2m,奇数时为N=2m+1
        x_i = -m * 0.5:0.5:m * 0.5; %d=0.5*λ
    end

    In_normal = In__ ./ max(In__);
    %figure(2);
    %plot(x_i,In_normal,'-bs');
    %title('泰勒线阵相对幅度方向图');
