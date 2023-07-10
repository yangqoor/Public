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
        f(m, n) = (sin(theta(m))).^2;
    end

end

surf(phi, theta, f)

for m = 1:length(theta)

    for n = 1:length(phi)
        x(m, n) = f(m, n) * sin(theta(m)) * cos(phi(n));
        y(m, n) = f(m, n) * sin(theta(m)) * sin(phi(n));
        z(m, n) = f(m, n) * cos(theta(m));
    end

end

figure

surf(x, y, z)
