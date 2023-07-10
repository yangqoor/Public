clc;
close all;
st = linspace(-0.15, 0.15, 1000);
std = (st .* 180) ./ pi;
std = linspace(-5, 5, 1000);
d = 0.05;
N = 1000;
lm = 1;
l = 50;
R = 50000;
y1 = sin((pi .* N .* d .* sin(st)) ./ lm);
y2 = ((pi .* N .* d .* sin(st)) ./ lm);
y8 = y1 ./ y2; %yΪ��ͨ�״﷽��ͼ����F
y = 10 .* log(y8);

plot(std, y);
title('�״﷽��ͼ����');
xlabel('��λ��/���㣩')
ylabel('����/db')
ste = l ./ (2 .* R); %��ste��Ϊ����
y11 = sin((pi .* N .* d .* sin(st - ste)) ./ lm);
y22 = ((pi .* N .* d .* sin(st - ste)) ./ lm);
yy = y11 ./ y22; %F(st-ste)
y111 = sin((pi .* N .* d .* sin(st + ste)) ./ lm);
y222 = ((pi .* N .* d .* sin(st + ste)) ./ lm);
yyy = y111 ./ y222; %F(st+ste)
yhe = yy + yyy; %δ����λ�任�ĺ�ͨ��
yhee = 10 .* log(yhe);
ycha = yy - yyy; %δ����λ�任�Ĳ�ͨ��
ychaa = 10 .* log(ycha);
figure
plot(std, yhee);
title('��λδת���ĺ�ͨ����Ӧ');
xlabel('��λ��/���㣩')
ylabel('���źŹ���/db')
figure
plot(std, ychaa);
title('��λδת���Ĳ�ͨ����Ӧ');
xlabel('��λ��/���㣩')
ylabel('���źŹ���/db')
