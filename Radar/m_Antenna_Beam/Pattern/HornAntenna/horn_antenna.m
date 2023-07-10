%%%%%%%%%%--------SOUGATA CHATTERJEEE---------------%%%%%%%%%%%%%%%%
%%%%%%%%%--------REALIZATION OF HORN ANTENNA-------%%%%%%%%%%%%%%%%

ie = 200;
je = 200;

cc = 2.99792458e8;
mu_0 = 4.0 * pi * 1.0e-7;
epsilon = 1;
sigma = 5.7e8;
epsilon1 = 1;
sigma1 = 0.001;
epsz = 8.8e-12;
dz = zeros(ie, je);
ez = zeros(ie, je);
hx = zeros(ie, je);
hy = zeros(ie, je);
ga = ones(ie, je);
gb = ones(ie, je);
gc = ones(ie, je);
gd = ones(ie, je);
%%%%%%-----Time Starts-------------------------------%%%%%
nmax = 170;
ddx = 1.0e-3;
ddy = ddx;
dt = .98 / (cc * sqrt((1 / ddx)^2 + (1 / ddy)^2));
%***************************************************
tw = 10;
t0 = 20;
T = 0.0;
%************PML PARAMETER*************************
gi2 = ones(ie);
gi3 = ones(ie);
fi1 = zeros(ie);
fi2 = ones(ie);
fi3 = ones(ie);

gj2 = ones(ie);
gj3 = ones(ie);
fj1 = zeros(ie);
fj2 = ones(ie);
fj3 = ones(ie);
npm1 = 50;

for i = 1:npm1
    xnum = npm1 - i;
    xd = npm1;
    xxn = xnum / xd;
    xn = 0.33 * ((xxn)^3);
    gi2(i) = 1.0 / (1.0 + xn);
    gi2(ie - 1 - i) = 1.0 / (1.0 + xn);
    gi3(i) = (1.0 - xn) / (1.0 + xn);
    gi3(ie - i - 1) = (1.0 - xn) / (1.0 + xn);
    xxn = (xnum - 0.5) / xd;
    xn = 0.25 * ((xxn)^3);
    fi1(i) = xn;
    fi1(ie - 2 - i) = xn;
    fi2(i) = 1.0 / (1.0 + xn);
    fi2(ie - 2 - i) = 1.0 / (1.0 + xn);
    fi3(i) = (1.0 - xn) / (1.0 - xn);
    fi3(ie - 2 - i) = (1.0 - xn) / (1.0 + xn);
end

npml = 50;

for j = 1:npml
    xnum = npml - j;
    xd = npm1;
    xxn = xnum / xd;
    xn = 0.33 * ((xxn)^3);
    gj2(j) = 1.0 / (1.0 + xn);
    gj2(je - 1 - j) = 1.0 / (1.0 + xn);
    gj3(j) = (1.0 - xn) / (1.0 + xn);
    gj3(je - j - 1) = (1.0 - xn) / (1.0 + xn);
    xxn = (xnum - 0.5) / xd;
    xn = 0.25 * ((xxn)^3);
    fj1(j) = xn;
    fj1(je - 2 - j) = xn;
    fj2(j) = 1.0 / (1.0 + xn);
    fj2(je - 2 - j) = 1.0 / (1.0 + xn);
    fj3(j) = (1.0 - xn) / (1.0 + xn);
    fj3(je - 2 - j) = (1.0 - xn) / (1.0 + xn);
end

for i = 100:180

    for j = 60:120
        ga(i, j) = 1 ./ (epsilon1 + (sigma1 * dt) / epsz);

        if i >= 120 && i <= 160 && j >= 94 && j <= 95 || i >= 120 && i <= 160 && j >= 105 && j <= 106 || i >= 118 && i <= 120 && j >= 93 && j <= 94 || i >= 118 && i <= 120 && j >= 106 && j <= 107 || i >= 116 && i <= 118 && j >= 92 && j <= 93 || i >= 120 && i <= 160 && j >= 107 && j <= 108 || i >= 114 && i <= 116 && j >= 91 && j <= 92 || i >= 114 && i <= 116 && j >= 108 && j <= 109 || i >= 112 && i <= 114 && j >= 90 && j <= 91 || i >= 112 && i <= 114 && j >= 109 && j <= 110 || i >= 110 && i <= 112 && j >= 89 && j <= 90 || i >= 110 && i <= 112 && j >= 110 && j <= 111 || i >= 108 && i <= 110 && j >= 88 && j <= 89 || i >= 108 && i <= 110 && j >= 111 && j <= 112 || i >= 106 && i <= 108 && j >= 87 && j <= 88 || i >= 106 && i <= 108 && j >= 112 && j <= 113 || i >= 104 && i <= 106 && j >= 86 && j <= 87 || i >= 104 && i <= 106 && j >= 113 && j <= 114 || i >= 102 && i <= 104 && j >= 85 && j <= 86 || i >= 102 && i <= 104 && j >= 114 && j <= 115 || i >= 100 && i <= 102 && j >= 84 && j <= 85 || i >= 100 && i <= 102 && j >= 115 && j <= 116 || i >= 98 && i <= 100 && j >= 83 && j <= 84 || i >= 98 && i <= 100 && j >= 116 && j <= 117 || i >= 96 && i <= 98 && j >= 82 && j <= 83 || i >= 96 && i <= 98 && j >= 117 && j <= 118 || i >= 94 && i <= 96 && j >= 81 && j <= 82 || i >= 94 && i <= 96 && j >= 118 && j <= 119 || i >= 92 && i <= 94 && j >= 80 && j <= 81 || i >= 92 && i <= 94 && j >= 119 && j <= 120 || i >= 90 && i <= 92 && j >= 79 && j <= 80 || i >= 90 && i <= 92 && j >= 120 && j <= 121 || i >= 88 && i <= 90 && j >= 78 && j <= 79 || i >= 88 && i <= 90 && j >= 121 && j <= 122 || i >= 86 && i <= 88 && j >= 77 && j <= 78 || i >= 86 && i <= 88 && j >= 122 && j <= 123 || i >= 84 && i <= 86 && j >= 76 && j <= 77 || i >= 84 && i <= 86 && j >= 123 && j <= 124 || i >= 82 && i <= 84 && j >= 75 && j <= 76 || i >= 82 && i <= 84 && j >= 124 && j <= 125 || i >= 80 && i <= 82 && j >= 74 && j <= 75 || i >= 80 && i <= 82 && j >= 125 && j <= 126 || i >= 160 && i <= 162 && j >= 90 && j <= 110
            l1 = ((sigma * dt) / epsz);
            ga(i, j) = 1 ./ (epsilon + l1);
        else
            ga(i, j) = 1 ./ (epsilon1 + (sigma1 * dt) / epsz);
        end

    end

end

epsilon2 = 1;
sigma2 = 0.001;

for i = 70:80

    for j = 80:120
        ga(i, j) = 1 ./ (epsilon2 + (sigma2 * dt) / epsz);
    end

end

for n = 1:nmax
    T = T + 1;
    %%%----calculation of Dz field-----------------%%%%%
    for j = 2:je

        for i = 2:ie
            dz(i, j) = gi3(i) * gj3(j) * dz(i, j) + gi2(i) * gj2(j) * .5 * (hy(i, j) - hy(i - 1, j) - hx(i, j) + hx(i, j - 1));
        end

    end

    %%%%----calculation of Ez field--------------%%%%
    for j = 2:je

        for i = 2:ie
            ez(i, j) = ga(i, j) * dz(i, j);
        end

    end

    source = -2.0 * ((T - t0) ./ tw) .* exp(-1.0 * ((T - t0) ./ tw).^2.0);
    ez(150, 100) = source;
    %%%%----calculation of Hx field--------------%%%%
    for j = 1:je - 1

        for i = 1:ie - 1
            hx(i, j) = fj3(j) * hx(i, j) + fj2(j) * 0.5 * (ez(i, j) - ez(i, j + 1));
        end

    end

    %%%%----calculation of Hy field--------------%%%%
    for j = 1:je - 1

        for i = 1:ie - 1
            hy(i, j) = fi3(i) * hy(i, j) + fi2(i) * 0.5 * (ez(i + 1, j) - ez(i, j));
        end

    end

    timestep = int2str(n);
    imagesc(ez);
    colormap(jet);
    colorbar
    title(['Ez at time step = ', timestep]);
    rectangle('Position', [94, 120, 12, 40], 'LineWidth', 3)
    rectangle('Position', [93, 118, 14, 2], 'LineWidth', 3)
    rectangle('Position', [92, 116, 16, 2], 'LineWidth', 3)

    rectangle('Position', [91, 114, 18, 2], 'LineWidth', 3)
    rectangle('Position', [90, 112, 20, 2], 'LineWidth', 3)
    rectangle('Position', [89, 110, 22, 2], 'LineWidth', 3)

    rectangle('Position', [88, 108, 24, 2], 'LineWidth', 3)
    rectangle('Position', [87, 106, 26, 2], 'LineWidth', 3)
    rectangle('Position', [86, 104, 28, 2], 'LineWidth', 3)

    rectangle('Position', [85, 102, 30, 2], 'LineWidth', 3)
    rectangle('Position', [84, 100, 32, 2], 'LineWidth', 3)
    rectangle('Position', [83, 98, 34, 2], 'LineWidth', 3)

    rectangle('Position', [82, 96, 36, 2], 'LineWidth', 3)
    rectangle('Position', [81, 94, 38, 2], 'LineWidth', 3)

    pause(0.005);
end
