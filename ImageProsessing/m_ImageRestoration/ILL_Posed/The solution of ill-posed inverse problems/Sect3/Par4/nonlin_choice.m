function [alf_opn]=nonlin_choice(mu,Alf,Nev,Delta,H,gamW)
mu=0;% Уравнение разрешимо
Dis=sqrt(Nev);%Delta=0.01;H=0.001/norm(U1);
Dz=gamW;% Dz=||z||
P=(mu+Delta+H*Dz);
% ОПН
gdis=Dis-P;% Относительные величины: 
%            Dis=||Az-U1||/||U1||,  P=delta+delta_A*||z||/||U1||


C=1.1;
ix=min(find(gdis<=0));%% функции < 0 -- a(delta)=b_1(delta)
ix1=ix-1;%% функции > 0 -- b(delta)
ix2=ix1-1;%% функции > 0 -- b_2(delta)

N1=Dis(ix2);Ps1=H*sqrt(Dz(ix));% ОПН

if N1^2 >= C*(mu+Delta+Ps1)^2-(C-1)*mu^2;alf_opn=Alf(ix);else alf_opn=Alf(ix1);end

figure(11);semilogx((Alf),Dis,'.-',Alf,P,'r.-');rr=get(gca,'YLim');hold on;
semilogx([Alf(ix) Alf(ix)],rr,'k');hold off;xlabel('\alpha')
legend('\beta(\alpha)','\Pi(\alpha)','\alpha_{\eta}',2)
set(gcf,'Name','Выбор параметра по ОПН в нелинейном случае','NumberTitle','off')

