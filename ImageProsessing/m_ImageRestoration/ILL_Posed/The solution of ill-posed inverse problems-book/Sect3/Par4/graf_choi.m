% Graf_choi
% графическа€ иллюстраци€ выбора параметра дл€ нелин. задачи потенциала
load nonlin_nev_H2;load nonlin_nev_H2 U1 U
%load nonlin_nev_unc
n=51;%m=2*n+1;
t=linspace(-2,2,n);h=t(2)-t(1);% —етки
%x=linspace(-3,3,m);hx=x(2)-x(1);
mu=0;Delta=0.01;H=0.001/norm(U1);
[alf_opn]=nonlin_choice(mu,Alf,Nev,Delta,H,gamW)