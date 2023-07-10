%2014 PyR 04

clc
close all
clear all

inc_t = pi / 100;
inc_p = (2 * pi) / 100;

theta = 0:inc_t:pi;
phi = 0:inc_p:(2 * pi);

for m = 1:length(theta)

    for n = 1:length(phi)
        f(m, n) = 1;
    end

end

surf(phi, theta, f)

% dimensionesf=length(f);
% numFilas=dimensionesf(1);
% numCol=dimensionesf(2);
%
% for i=1:1:numFilas
%     for j=1:1:numCol
%         x=r*sin(theta)*cos(phi);
%         y=r*sin(theta)*sin(phi);
%         z=r*cos(theta);
%     end
% end

for m = 1:length(theta)

    for n = 1:length(phi)
        x(m, n) = f(m, n) * sin(theta(m)) * cos(phi(n));
        y(m, n) = f(m, n) * sin(theta(m)) * sin(phi(n));
        z(m, n) = f(m, n) * cos(theta(m));
    end

end

figure

surf(x, y, z)
