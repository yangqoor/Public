X = imread('手.jpg');
X = rgb2gray(X);
imhist(X);
X = double(X);
[M, N] = size(X);
hist = zeros(1, 256);
tic;

for i = 1:1:M

    for j = 1:1:N
        fi = X(i, j);
        hist(fi + 1) = hist(fi + 1) + 1;
    end

end

i = 1:1:256;
figure
plot(i, hist);
p = zeros(1, 256);

for i = 1:1:256
    p(i) = hist(i) / (M * N);
end

E1 = zeros(1, 256);
E2 = zeros(1, 256);
P = zeros(1, 256);
E = zeros(1, 256);

for t = 1:1:256

    for i = 1:1:t
        P(t) = P(t) + p(i);
    end

    if (P(t) > 0 && P(t) < 1)
        %               Q=0;
        for i = 1:1:t
            E1(t) = E1(t) - (p(i) / P(t)) * log(p(i) / P(t) + eps);
        end

        %            A(s)=2*log(P(s)+eps)-log(Q+eps);
        %            R=0;
        for i = t + 1:1:256
            E2(t) = E2(t) - (p(i) / (1 - P(t))) * log(p(i) / (1 - P(t)) + eps);
        end

        %            B(s)=2*log(1-P(s)+eps)-log(R+eps);
    end

    E(t) = E1(t) + E2(t);
end

MAX = 0.000001;

for t = 68:1:156
    %i=1:1:s;
    %j=s+1:1:256;
    if (E(t) > MAX)
        MAX = E(t);
        th = t;
    end

end

% end
% [max,colum2]=max(E);
% th=colum2;
g = zeros(M, N);

for i = 1:1:M

    for j = 1:1:N

        if (th < X(i, j))
            X(i, j) = 1;
            g(i, j) = X(i, j);
        else X(i, j) = 0;
            g(i, j) = X(i, j);
        end

    end

end

X = X .* 255;
X = uint8(X);
imshow(X);
t_eclapsed = toc;
