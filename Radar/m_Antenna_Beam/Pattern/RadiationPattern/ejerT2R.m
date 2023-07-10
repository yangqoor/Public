%2014 PyR 04

clc
close all
clear all

inc_t = pi / 100;
inc_p = (2 * pi) / 100;

theta = (-pi / 2):inc_t:(pi / 2);
phi = 0:inc_p:(2 * pi);

q = [1 6 9];

for m = 1:length(theta)

    for n = 1:length(phi)

        for i = 1:length(q)
            f(m, n, i) = (cos(theta(m))).^q(i);
        end

    end

end

surf(phi, theta, f(:, :, 1))
shading flat
title('q=1')

figure
surf(phi, theta, f(:, :, 2))
shading flat
title('q=6')

figure
surf(phi, theta, f(:, :, 3))
shading flat
title('q=9')

for m = 1:length(theta)

    for n = 1:length(phi)

        for i = 1:length(q)
            x(m, n, i) = f(m, n, i) * sin(theta(m)) * cos(phi(n));
            y(m, n, i) = f(m, n, i) * sin(theta(m)) * sin(phi(n));
            z(m, n, i) = f(m, n, i) * cos(theta(m));
        end

    end

end

figure

surf(x(:, :, 1), y(:, :, 1), z(:, :, 1))
shading flat
title('q=1')

figure
surf(x(:, :, 2), y(:, :, 2), z(:, :, 2))
shading flat
title('q=6')

figure
surf(x(:, :, 3), y(:, :, 3), z(:, :, 3))
shading flat
title('q=9')
