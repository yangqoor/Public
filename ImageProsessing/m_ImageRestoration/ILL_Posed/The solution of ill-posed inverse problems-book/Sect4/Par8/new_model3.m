function [s,a0,hsf,A,u,N,C_min,C_max]=new_model3(nummer);

if  nummer == 1;
load solution_mon sx sy0;s=sx;a0=sy0;N=length(sx);
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
     load solution_w11 sx sy0;N=length(sx);s=sx;h=s(2)-s(1);hsf=h;
  a0=sy0;
  p=100;%p=100;
[XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);%u=righ_hand(s,p);
A=K1*h;A(:,1)=A(:,1)*0.5;A(:,end)=A(:,end)*0.5;
u=(A*a0')';
C_min=4.9;C_max=12.5;

else 
   N=61;s=linspace(0,1,N);h=s(2)-s(1);hsf=h;a0=(s-1).^2;
   C_min=0;C_max=1.1;%-0.02 1.1
  p=20;
[XX,TT]=meshgrid(s,s);K1=1./(1+p*(XX-TT).^2);
A=K1*h;A(:,1)=A(:,1)*0.5;A(:,end)=A(:,end)*0.5;
u=(A*a0')';

end
