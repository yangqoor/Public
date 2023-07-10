function [s,a0,hsf,A,u,N,C_min,C_max]=new_model(nummer);

if  nummer == 1;
N7=51;N3=N7;N=N3+N7-1;% размерность задачи
s7=linspace(0,1,N7);s3=linspace(0,1,N3);% Для простоты сетки -- равномерные.
% Точное модельное решение
a0=[ 7*sqrt(abs(s7-1))+5  5*ones(size(s3(1:end-1)))];
s=[ s7 s7(end)+s3(2:end)];
hsf=s(2)-s(1);h=hsf;% Шаг сетки решения
% Априорная информация
C_min=4.9;C_max=12.5;
% Точные данные задачи
p=100;%p=100;
[XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);%u=righ_hand(s,p);
A=K1*h;A(:,1)=A(:,1)*0.5;A(:,end)=A(:,end)*0.5;
%uu=righ_hand2(s,p);
u=(A*a0')';

elseif nummer==2;
   t=linspace(0,1,91);x=t;s=t;N=length(t);
   hsf=t(2)-t(1);z=(1-t.^2).^2;a0=z; % Точные данные
   [XX,TT]=meshgrid(x,t);K1=tril(ones(size(XX)),-1);
   K1(:,1)=K1(:,1)*0.5;d=0.5*diag(ones(1,N));
   A=(K1+d)*hsf;
   u=s-2*s.^3/3+s.^5/5;
   C_min=-0.02; C_max=1.1;
   
elseif nummer==3;
   N=61;s=linspace(0,1,N);h=s(2)-s(1);hsf=h;a0=(s-1).^2;
   C_min=-0.02;C_max=1.1;
  p=20;
[XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);
A=K1*h;A(:,1)=A(:,1)*0.5;A(:,end)=A(:,end)*0.5;
%uu=righ_hand2(s,p);
u=(A*a0')';
else end
