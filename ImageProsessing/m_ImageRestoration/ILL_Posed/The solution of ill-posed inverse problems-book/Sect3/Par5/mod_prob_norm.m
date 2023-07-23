function [a0,s,h,A,u,u1,C_min,RU,RA]=mod_prob_norm(numm);

%  Задание модельных данных

if numm==1;load stand_err1 RU RA
   s=linspace(-1,1,51);% Сетка аргумента
   h=s(2)-s(1);% Шаг сетки решения
   p=100;
   [XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);
   a0=(1+sign(s)); %   Модельное решение
   A=K1*h;A(1,:)=A(1,:)*0.5;A(end,:)=A(end,:)*0.5;NA=norm(A);
   u=A*a0';u1=K1*h*a0';
   C_min=-0.05;

elseif numm==2;load stand_err2 RU RA
   s=linspace(-1,1,51);h=s(2)-s(1);a0=(sign(s).*(1-abs(s)));;
   p=100;
[XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);
A=K1*h;A(1,:)=A(1,:)*0.5;A(end,:)=A(end,:)*0.5;NA=norm(A);
u=A*a0';u1=K1*h*a0';
C_min=-1.05;

elseif numm==3;load stand_err5 RU RA
   s=linspace(-1,1,51);h=s(2)-s(1);a0=sign(s).*(s.^2-1);% (1-abs(s));
   p=100;
[XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);
A=K1*h;A(1,:)=A(1,:)*0.5;A(end,:)=A(end,:)*0.5;NA=norm(A);
u=A*a0';u1=K1*h*a0';
C_min=-0.01;

else 
load stand_err_end RU RA
   s=linspace(-1,1,51);h=s(2)-s(1);a0=sign(s-0.5)-2*sign(s+0.5);% (1-abs(s));
   p=100;
[XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);
A=K1*h;A(1,:)=A(1,:)*0.5;A(end,:)=A(end,:)*0.5;NA=norm(A);
u=A*a0';u1=K1*h*a0';
C_min=-0.01;
   
end
u=u/NA;A=A/NA;u1=u1/NA;% Нормированные данные задачи
