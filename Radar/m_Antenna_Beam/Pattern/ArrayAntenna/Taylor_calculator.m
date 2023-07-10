%���������
%d:��Ԫ���d=1/2��ʾ������Ϊd=��/2
%N:Ϊ��Ԫ��
%R0dB:Ϊ�����ƽҪ��
%n__:����Ƶڼ������n__
%���������
%x���Ƕ�0-180��
%x_i:����λ��
%SxdB��̩��������Է��ȷ���ͼ
%In_normal��̩�չ�һ����������ֵIn_normal
%���ã�[x,x_i,In_normal,SxdB] = Taylor_calculator(0.5,19,6,20);

function [x, x_i, In_normal, SxdB] = Taylor_calculator(d, N, n__, R0dB)

    x = 2:1:178; %�Ƕ�
    r0 = 10^(R0dB / 20); %�����ƽҪ��20lgR0=20dB
    A = (1 / pi) .* acosh(r0); %���ݸ����ƽҪ��r0��A
    n_ = ceil(2 * A^2 + 1/2); %���nһƲ��n_��2A^2+0.5.

    if n_ < n__;
        n_ = n__;
    end

    %��̩�շ���ͼ����������Xn
    for n = 1:1:n_ - 1;
        Xn(n) = n_ * sqrt((A^2 + (n - 1/2)^2) / (A^2 + (n_ - 1/2)^2));
    end

    %for n=n_:1:N;
    % Xn(:,n) = n;
    %end

    %��̩�����к��������ӷ���ͼ
    Xu = N * d * cos(x .* pi / 180); %Xu=L/��cos��,L=Nd,dΪ��Ԫ��࣬ȡd=��/2��xΪ�ǶȻ��ɻ��ȣ���=x*(pi/180),��Xu=N/2*cos(x.*pi/180).

    for n = 1:1:n_ - 1;
        Sx0(:, n) = 1 - ((Xu.^2) ./ (Xn(n).^2));
    end

    Sx0_p = prod(Sx0');

    for n = 1:1:n_ - 1;
        Sx1(:, n) = 1 - ((Xu.^2) ./ (n.^2)); %��ά����
    end

    Sx1_p = prod(Sx1');
    Sx = cosh(pi * A) .* (((sin(pi * Xu) .* Sx0_p) ./ ((pi * Xu) .* Sx1_p)));
    Sx_max = max(Sx);
    SxdB = 20 * log10((abs(Sx)) / Sx_max); %��һ������ͼ
    %figure(1);
    %plot(x,SxdB);
    %title('̩��������Է��ȷ���ͼ');

    %����
    for i = 1:1:n_ - 1;
        Si(:, i) = factorial(n_ - 1)^2 ./ factorial(n_ - 1 + i) ./ factorial(n_ - 1 - i);

        for n = 1:1:n_ - 1;
            In(:, n) = 1 - (i ./ (Xn(n))).^2;
        end

        In_p(:, i) = prod(In');
    end

    Sian_ = Si .* In_p;

    if mod(N, 2) == 0 % % NΪż��
        m = N / 2; %��Ԫ����Ϊż��ʱN=2m������ʱΪN=2m+1

        for n = 1:1:m;

            for i = 1:1:n_ - 1;
                s_cos(:, i) = Sian_(i) .* cos(2 * pi * i * (2 * (n - 1) + 1) / 2 / N);
            end

            In_m(:, n) = 1 + 2 * sum(s_cos');
        end

        for n = 1:1:m;
            In_(:, n) = In_m(m + 1 - n); %������һ�߼�������ת
        end

        In__ = [In_, In_m];

    elseif mod(N, 2) == 1 % % NΪ����
        m = (N - 1) / 2; %��Ԫ����Ϊż��ʱN=2m,����ʱΪN=2m+1

        for n = 1:1:m + 1;

            for i = 1:1:n_ - 1;
                s_cos(:, i) = Sian_(i) .* cos(2 * pi * i * (n - 1) / N);
            end

            In_m(:, n) = 1 + 2 * sum(s_cos');
        end

        for n = 1:1:m;
            In_(:, n) = In_m(m + 2 - n); %������һ�߼�������ת
        end

        In__ = [In_, In_m];
    end

    if mod(N, 2) == 0 % % NΪż��
        m = N / 2; %��Ԫ����Ϊż��ʱN=2m������ʱΪN=2m+1
        x_i = (-m + 0.5) * 0.5:0.5:(m - 0.5) * 0.5;
    elseif mod(N, 2) == 1 % % NΪ����
        m = (N - 1) / 2; %��Ԫ����Ϊż��ʱN=2m,����ʱΪN=2m+1
        x_i = -m * 0.5:0.5:m * 0.5; %d=0.5*��
    end

    In_normal = In__ ./ max(In__);
    %figure(2);
    %plot(x_i,In_normal,'-bs');
    %title('̩��������Է��ȷ���ͼ');
