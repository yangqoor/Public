clc
clear
close all
% ===========1-D===============
sita = -pi / 2:0.001:pi / 2; % ��ȡ-pi/2��pi/2
D = 2;
d = 0.1;                     % d���ǻ����õ��Ǹ�dx
lamda = 0.05;                % ��ȡ0.05������

sum = 0;
len = length(sita);
pattern = zeros(1, len);
i = 1;

for sita = -pi / 2:0.001:pi / 2

    for x = -D / 2:d:D / 2
        sum = sum + exp(1j * 2 * pi * sin(sita) * x / lamda) * d; % ����ǻ��ֵĹ��̣������ʵ��
    end

    pattern(i) = sum;
    i = i + 1;
    sum = 0; % ��ѭ����ÿ��pattern��i���������£�ÿ��ֵ�ǹ����ض��ȶ�Ӧ��ֵ�������ǹ��ڦȵĺ���
end

figure(1);
sita = linspace(-pi / 2, pi / 2, len);
plot(sin(sita), abs(pattern));
title('1-D �״﷽��ͼ');

% ============2-D================
clc
clear

size = 2000;

A = zeros(size, size);

for m = 1:10

    for n = 1:10
        A(m, n) = 1;
    end

end

A = circshift(A, [size * 0.5 - 5, size * 0.5 - 5]); % ѭ����λ�������Ͻ�10*10��ȫ1 ����Ū��A��������
x = 1:size;
y = 1:size;
z = fftshift(abs(fft2(A))); % ֱ����2-D fft  ���ۼ����ñʼǱ��ϵļ�¼

figure(2);
h1 = mesh(x, y, z);         % mesh �ǻ���άͼ�ĺ���
view([0, 0, 1]);            % 0 0 -1 �ֱ��ʾ��ֱ������ϵ�У������꣨0 0 -1�������������ɵ���άͼ
title('(2-D)���������߷���ͼ����ͼ');
grid on;
figure(3);
h2 = mesh(x, y, z);
view([1, 1, 1]);            % ����Ŀ�һ���������ͼ
title('(2-D)���������߷���ͼб��ͼ');
