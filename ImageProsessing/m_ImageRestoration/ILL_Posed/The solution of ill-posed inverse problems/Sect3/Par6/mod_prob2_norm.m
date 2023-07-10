function [a0,s,h,A,u,u1,C_min,RU,RA]=mod_prob2_norm(numm);

if numm==1;%  Решение из класса W_1^2
N7=51;N3=N7;N=N3+N7-1;%
s7=linspace(0,1,N7);s3=linspace(0,1,N3);% Для простоты сетки -- равномерные.
% Точное модельное решение
a0=[ 7*(abs(s7-1)).^(3/2)+0  0*ones(size(s3(1:end-1)))];% 
s=[ s7 s7(end)+s3(2:end)];
h=s(2)-s(1);% Шаг сетки решения
% Априорная информация
C_min=-10;
% Точные данные задачи
p=100;%p=500;
[XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);
A=K1*h;A(1,:)=A(1,:)*0.5;A(end,:)=A(end,:)*0.5;NA=norm(A);
%uu=righ_hand2(s,p);
u=A*a0';u1=K1*h*a0';
load err_realization_20 RU RA;% Для n=51!
elseif numm==2;
   s=linspace(0,1,101);h=s(2)-s(1);a0=(s-1).^2;C_min=-5;
   p=100;%p=500;
[XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);
A=K1*h;A(1,:)=A(1,:)*0.5;A(end,:)=A(end,:)*0.5;NA=norm(A);
%uu=righ_hand2(s,p);
u=A*a0';u1=K1*h*a0';
load err_realization_20 RU RA;% Для n=51!
elseif numm==3;
   s=linspace(0,1,101);h=s(2)-s(1);a0=(s-0.5).^2;C_min=-2;
   p=100;%p=500;
[XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);
A=K1*h;A(1,:)=A(1,:)*0.5;A(end,:)=A(end,:)*0.5;NA=norm(A);
%uu=righ_hand2(s,p);
u=A*a0';u1=K1*h*a0';
load err_realization_20 RU RA;% Для n=51!
else end
u=u/NA;A=A/NA;u1=u1/NA;% Нормированные данные задачи
