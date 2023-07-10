%--------------------------------------------------------------------------
%   复数除法圆 定理验证
%--------------------------------------------------------------------------
clear;clc;close all
rng(2021);

a1 = 7 + 2j;
a2 = 3 + 4j;
b1 = 5 + 6j;
b2 = 7 + 8j;


idx = 1;
for theta_degree = 0:360
    theta = deg2rad(theta_degree);
    c(idx) = (a1 + a2.*exp(1j.*theta))/(b1 + b2.*exp(1j.*theta));
%     plot(c);grid on;axis equal
%     title(['角度->' num2str(theta_degree)])
    idx = idx + 1;
%     drawnow
end

figure(1)
plot(c);grid on;axis equal

vector_a1 = [real(a1) imag(a1)]';
vector_a2 = [real(a2) imag(a2)]';
vector_b1 = [real(b1) -imag(b1)]';
vector_b2 = [real(b2) -imag(b2)]';
vector_a_star = [vector_a1' -vector_a2']';
P = [0 -1;1 0];
B = [vector_b1 P*vector_b1 vector_b2 P*vector_b2];

ha = vector_a1'*vector_a1-vector_a2'*vector_a2;
hb = vector_b1'*vector_b1-vector_b2'*vector_b2;
%--------------------------------------------------------------------------
%   圆心 半径
%--------------------------------------------------------------------------
c0 = 1/hb*B*vector_a_star
rc = sqrt(1/hb^2*vector_a_star'*(B'*B)*vector_a_star-ha/hb)

hold on
plot(c0(1),c0(2),'r.');title(['半径 -> ' num2str(rc)])


