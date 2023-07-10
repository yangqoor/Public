%  monot_reg

%  Можно использовать модули  Monot_convex и Monot_decr
n=size(AA,2);
%b=U;T=-tril(ones(n));T(:,1)=1;
T=triu(ones(n));
zz1=zeros(n,1);B=[AA*T];b=U-5*AA*ones(n,1);
zz1=lsqnonneg(B,b);zz1(end)=0;
zz=T*(zz1(1:n))+5;Umon=AA*zz;

nev_min=norm(U-Umon)/norm(U);Error=norm(zz'-a0,inf)/norm(a0,inf);
disp(['   Residual = ' num2str(nev_min) '   C_error = ' num2str(Error)]);

Var_error_m=Var1(zz'-a0)/Var1(a0)

figure(103);subplot(1,2,1);plot(s,a0,'r',s,zz','.-');
xlabel('x');ylabel('z(x)');
set(gca,'FontName',FntNm);
title('Точное и приближенное решение')
legend('Точное решение','Приближенное решение',1);
%subplot(1,2,2);plot(s,U3,'r',s,Umon3,'.');
old_val(s,U,Umon);
xlabel('s');ylabel('u(s)');
set(gca,'FontName',FntNm);
title('Приближ. и вычисл. правая часть')
legend('u_{\delta}','Az_{приближ}',1);
set(gcf,'Name','Монотонное решение','NumberTitle','off','Position',[435 237 560 420])
