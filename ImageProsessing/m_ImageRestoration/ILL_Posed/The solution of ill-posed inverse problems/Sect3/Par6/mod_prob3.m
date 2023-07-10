function [a0,s,h,A,u,u1,C_min,RU,RA]=mod_prob3(numm);

if numm==1;%  Решение из класса W_1^2
   N=121;s=linspace(0,1,N);h=s(2)-s(1);% Шаг сетки решения
% Точное модельное решение
%a0=1+s.*(s-0.4).*(s-0.8);% 
x=[0 0.2 0.6 1];y=[0 0.6 0.3 1];a0=interp1(x,y,s,'cubic');
% Априорная информация
C_min=-0.1;
% Точные данные задачи
p=100;%p=500;
[XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);
A=K1*h;A(1,:)=A(1,:)*0.5;A(end,:)=A(end,:)*0.5;
%uu=righ_hand2(s,p);
u=A*a0';u1=K1*h*a0';
load err_realization_21 RU RA;% Для n=51!
else end