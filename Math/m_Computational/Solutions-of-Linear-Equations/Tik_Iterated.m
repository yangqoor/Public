%%%%%%%%%%%%%%%%%%%%%%%% XMLiu 2016.4.21 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Consider the integral equation:
% "int(e^(ts)*x(s),s,0,1)=y(t)=(e^(t+1)-1)/(t+1),0<=t<=1".
% The real solution is x(t)=e^t.
% Find the numerical solution with iterated Tiknohov regularization method,
% the iterated method is regularization-adjoint-conjugate gradient method.
% Solve the equation "Kx=y",
% K: integral operator
% y: right side of equation
% x_real: real solution
% x_alpha: numerical solution
% delta: the error
% alpha: a priori regularization parameter
% beta: step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
N_s = 50;
N_t = 50;
s = 0:1 / N_s:1;
t = 0:1 / N_t:1;
K = zeros(N_s, N_t); % Creat the matrix K
y = zeros(N_t, 1);
x_real = exp(t)'; % The right result  t * 1
plot(t, x_real, 'g')
xlabel('t')
ylabel('x')
hold on
delta = 1e-6; %1e-4; %1e-8; %

for i = 1:N_s

    for j = 1:N_t
        K(i, j) = 1 / N_s * exp(s(i) * t(j)); % Compound rectangle formula
    end

    y(i) = (exp(s(i) + 1) - 1) ./ (s(i) + 1);
end

x_alpha = ones(length(x_real), 1); % The solved value of x
alpha = 1e-8;
I = eye(size(K' * K));
beta = 1;
Number = 0;

while abs(K * x_alpha(1:N_t) - y) > delta
    p = K * x_alpha(1:N_t) - y;
    v = (sqrt(alpha)) ^ (-1) * p;
    r = alpha * x_alpha(1:N_t) + K' * p;
    x_alpha(1:N_t) = x_alpha(1:N_t) - beta * r;
    beta = trace((-r) * ((alpha * I + K' * K) * (-r))') / norm((alpha * I + K' * K) * (-r)) ^ 2;
    Number = Number + 1;
end

plot(t(1:N_t), x_alpha(1:N_t), 'b-.')
legend('x-real', 'x-alpha');
ReErr = abs(x_real(1:N_t) - x_alpha(1:N_t)) ./ abs(x_real(1:N_t));
figure;
plot(t(1:N_t), ReErr(1:N_t), 'r.')
xlabel('t')
ylabel('ReErr')
