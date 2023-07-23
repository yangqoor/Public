function FKu = conv2d(fu,FK)
%  Вычисление фурье-преобразования двумерной свертки функций u K
%  как произведение их фурье-образов fu и FK

n = max(size(fu));
M = 2*n;
z = real(ifft2( ((fft2(fu,M,M)) .* FK), M,M ));
FKu = z(1:n,1:n);

