function y = qumo(x1, x2)
    %����·�źŽ���ȡģ����ϳ�һ·�ź�
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [M, N] = size(x1);

    for i = 1:N
        y(1:M, i) = sqrt(x1(1:M, i).^2 + x2(1:M, i).^2);
    end

    w = y(:)';
    i = 0:length(w) - 1;
    plot(i, abs(w));
