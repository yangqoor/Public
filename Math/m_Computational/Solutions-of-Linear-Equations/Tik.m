%%%%%%%%%%%%%%%%%%%%%%%% XMLiu 2016.4.21 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Consider the integral equation:
% "int(e^(ts)*x(s),s,0,1)=y(t)=(e^(t+1)-1)/(t+1),0<=t<=1".
% The real solution is x(t)=e^t.
% Find the numerical solution with Tiknohov regularization method,
% Solve the equation "Kx=y",
% K: integral operator
% y: right side of equation
% x_real: real solution
% x_alpha: numerical solution
% alpha: a priori regularization parameter
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
plot(t(1:N_t), x_real(1:N_t), 'g')
xlabel('t')
ylabel('x')
hold on

for i = 1:N_s

    for j = 1:N_t
        K(i, j) = 1 / N_s * exp(s(i) * t(j)); % Compound rectangle formula
    end

    y(i) = (exp(s(i) + 1) - 1) ./ (s(i) + 1);
end

alpha = 1e-8;
I = eye(size(K' * K));
R = inv(alpha * I + K' * K) * K';
x_alpha = R * y; % the solved value of x
plot(t(1:N_t), x_alpha', 'b-.')
legend('x-real', 'x-alpha');
ReErr = abs(x_real(1:N_t) - x_alpha) ./ abs(x_real(1:N_t));
figure;
plot(t(1:N_t), ReErr, 'r.')
xlabel('t')
ylabel('ReErr')
