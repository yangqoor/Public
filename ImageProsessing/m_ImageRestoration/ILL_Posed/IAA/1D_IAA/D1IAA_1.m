% clear all;
% close all;
% clc;
% K=500;
function x_1 = D1IAA_1(y, K)
    M = length(y);

    for m = 1:M k = 0:K - 1; %定义a矩阵
        A(m, k + 1) = exp(j * (m - 1) * 2 * pi * k / K);
    end

    %发送端
    % AM = 1;
    % omega = pi/3;
    % omega1 = pi;
    % phi = 0.1;
    % m = (1:M).';
    % y1 = AM*exp(j*(omega*m+phi)) + AM*exp(j*(omega1*m+phi)) ;
    % e=0+sqrt(0.1)*randn(M,1);
    % y2=y1+e; %observation
    % Y2=fft(y2,K);
    % Ay2=abs(Y2);

    x = ones(K, 1);
    power = abs(x) .^ 2; %使用算法
    P = diag(power);
    R = A * P * A';
    Q = inv(R);

    for t = 1:15

        for n = 1:K

            x_1(t, n) = A(:, n)' * Q * y / (A(:, n)' * Q * A(:, n));

        end

        power = abs(x_1(t, :)) .^ 2; %使用算法
        P = diag(power);
        R = A * P * A';
        Q = inv(R);

    end

    % for h=2:15
    %     if norm(x_1(h,:)-x_1(h-1,:))/norm(x_1(h,:))<=1e-1 break;
    %     end
    % end
    x_1 = x_1(end, :);
    % y3=A*x_1';                             %还原出来的信号
    % Y3=fft(y3,K);
    % Ay3=abs(x_1);
    %
    %
    %
    % % Ay4 = fft(y2,K);
    %
    % figure;
    % b=0:K-1;
    % plot(b*360/K,Ay2/max(Ay2),'b'), hold on;
    % xlabel('频率');
    % ylabel('振幅');
    %
    % % plot(b*2*pi/K,Ay4,'k+-'),hold on;
    % b_1=0:K-1;
    % plot(b_1*360/K,Ay3/max(Ay3),'r'),hold on;
    %
    % xlabel('频率');
    % ylabel('振幅');
    %
    % legend('dft','proposed')
    % % title('处理后的频谱');
