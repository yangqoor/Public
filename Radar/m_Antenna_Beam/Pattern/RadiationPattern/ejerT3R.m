%2014 PyR 04

clc
close all
clear all

inc_t = pi / 100;
inc_p = (2 * pi) / 100;

theta = (-pi / 2):inc_t:(pi / 2);
phi = 0:inc_p:(2 * pi);

%CASO 1

Nx = 8;
Ny = 8;
alfa_x = 0;
alfa_y = 0;

for m = 1:length(theta)

    for n = 1:length(phi)
        fi_x = (pi / 2) * sin(theta(m)) * cos(phi(n)) + alfa_x;
        fi_y = (pi / 2) * sin(theta(m)) * sin(phi(n)) + alfa_y;

        valor = 0;

        for n2 = 1:1:Nx

            for m2 = 1:1:Ny
                %For complex Z=X+i*Y, exp(Z) = exp(X)*(COS(Y)+i*SIN(Y)).

                X1 = 0;
                X2 = 0;
                Y1 = n2 * fi_x;
                Y2 = m2 * fi_y;

                valor = valor + (exp(1i * n2 * fi_x)) * (exp(1i * m2 * fi_y));

            end

        end

        f(m, n) = valor;

    end

end

title('Nx=8,Ny=8,alfa_x=0,alfa_y=0')
f = abs(f) / max(max(abs(f)));
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
title('Nx=8,Ny=8,alfa_x=0,alfa_y=0')
