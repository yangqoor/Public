%���������� ���и�fresnelC ���������
x = -50:50;
% syms x
C = fresnelc(x); % ԭ����mfun('FresnelC',x)������
S = fresnels(x);
I0 = 1;
T = (C+1/2).^2 + (S+1/2).^2;
I = (I0/2)*T;
plot(x,I);
xlabel('x');
ylabel('I(x)');
title('Intensity of Diffracted Wave');