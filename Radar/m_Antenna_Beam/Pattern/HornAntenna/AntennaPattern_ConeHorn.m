% 圆锥喇叭天线方向图
% www.pudn.com
b = linspace(-90, 90, 100);
c = b .* pi ./ 180;
bb = linspace(-90, 90, 100);
cc = bb .* pi ./ 180;
a = ones(1, 100);
n1 = [];

for d1 = c
    q = 2 * besselj(1, 3 * pi * sin(d1));
    qq = abs(q / (3 * pi * sin(d1)));
    n1 = [n1 qq];
    n2 = n1.' * a;
end

% figure
% plot(b, 20 * log10(n1));
figure
plot(b, n1);
Z1 = a.' * (n1 .* cos(c));
X1 = (sin(cc)).' * (n1 .* sin(c));
Y1 = (cos(cc)).' * (n1 .* sin(c));
% 需要时启用
figure
surf(X1, Y1, Z1);
shading interp;
view([35, 30]);
axis([-1 1 -1 1 0 1]);
% fft验证
n1_fft = abs(fft(n1,20));
figure
title('方向图fft')
plot(fftshift(n1_fft))

% 阵列方向图
ya = linspace(-15, 15, 100); yaa = ya .* pi ./ 180; %仰角范围
fb = linspace(-25, 25, 100); fbb = fb .* pi ./ 180; %方位角范围
w = sin(yaa);
ww = cos(fbb);
www = sin(fbb);
wwww = ones(100, 100);
% 仰角15度 方位角20度
d = w.' * ww - wwww .* sin((pi / 180) * 15) .* cos((pi / 180) * 20);
dd = w.' * www - wwww .* sin((pi / 180) * 15) .* sin((pi / 180) * 20);

z1 = 0; z2 = 0;

for n = -3:3 % n=1:7 %矩阵时启用
    for m = 0:6 - abs(n) % m=1:7 %矩阵时启用
        z1 = z1 + (exp(i * ((2 * pi) / 8) * ((m + 0.5 * abs(n)) * (2.5 * 8) * d + n * (2.5 * 8 * cos(pi / 6)) * dd))); %六边形阵
        % z1=z1+(exp(i*((2*pi)/8)*(((m-1))*(2*8)*d+(n-1)*(2*8)*dd)));%矩阵
    end
end

Z = ((abs(z1) + eps) / 49) .* (cos(yaa).' * ones(1, 100));
X = ((abs(z1) + eps) / 49) .* (sin(yaa).' * ones(1, 100)) .* (ones(100, 1) * sin(fbb));
Y = ((abs(z1) + eps) / 49) .* (sin(yaa).' * ones(1, 100)) .* (ones(100, 1) * cos(fbb));

figure
surf(X, Y, Z);
% surf(X,Y,20*log10(((abs(z1)+eps)/z2).*n2));四种不同显示方法
% surf(ya,fb,(abs(z1)+eps)/z2);
% surf(fb,ya,20*log10(((abs(z1)+eps)/64)));
shading interp;
view([35, 30]);
% axis([-1 1 -1 1 0 1]);
% axis([-1 1 -1 1 -60 0]);
% axis([-90 90 -90 90 0 1]);
% axis([-20 20 -20 20 -60 0]);
