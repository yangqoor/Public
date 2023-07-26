function x = D1IAA_1err(y, K)
    M = length(y);
    k = 0:K - 1;
    m = 0:M - 1;
    A = exp(1i * 2 * pi * m.' * k / K);
    s = ones(K, 1);
    p = s .^ 2;
    P = diag(p);
    inter = 15;

    for t = 1:inter
        R = A * P * A';
        Q = A' / R;
        Q_1 = Q * A;
        x1 = (Q * y) ./ diag(Q_1); %为什么这里要对矩阵求对角阵？？？？？？？？
        p = x1 .^ 2
        P = diag(p);
    end

    x = abs(x1);
