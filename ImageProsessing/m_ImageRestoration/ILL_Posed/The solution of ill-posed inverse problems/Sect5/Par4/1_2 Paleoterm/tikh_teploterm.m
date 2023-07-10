% tikh_teploterm

% Используется в Paleoterm. Можно использовать автономно, раскомментировав 
% следующую строку.
%load load basis1_2.mat A u_k du_k info;load overdet.mat UU;delta=0.001;


KK1=AA;ud1=U;
z=MU';h=t(2)-t(1);
%
if delta==0;alf0=0.3e-6;q=(0.95);elseif delta==0.01;alf0=delta/100;q=0.9;
elseif delta==0.001;alf0=1e-5;q=0.9;end
alf0=1e-4;q=0.7;% Гауссианы 41
alf0=1e0;q=0.5;

C=1.;Del=delta+Residual; 
Alf=[];Dis=[];Dz=[];Nz=[];Vz=[];Disz=[];MT=[];
for kk=1:40;alf=alf0*q.^(kk-1);
   [zr3,dis3,v3]=tikh_alf(KK1,ud1,h,u_k,d2u_k,alf);Alf=[Alf alf];Dis=[Dis dis3];
   zr=u_k*zr3;Vz=[Vz v3];
   dz=norm(zr(2:end)-z(2:end),inf)/norm(z(2:end),inf);Dz=[Dz dz];nz=norm(zr);Nz=[Nz nz];
   mt=sqrt(alf*nz^2+dis3^2);MT=[MT log10(mt)];
figure(22);subplot (1,2,1);
plot (t(2:end),zr(2:end), '.-',t(2:end),z(2:end), 'r-');set(gca,'FontName',FntNm);
legend ('Calc' ,'Exact' , 1 ) ;
subplot (3,2,2);plot (log10(Alf),log10(Dis), 'r.-',...,
   [-18 log10(alf0)],[log10(C*Del) log10(C*Del)], 'k-');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'XTickLabel',[]);
ylabel('lg(Невязка(\alpha))');
title('Относительная невязка уравнения');text(log10(alf0)+0.5,log10(Del),'lg(\Delta)')
subplot (3,2,4);plot (log10(Alf),(Dz), 'r.-');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'YLim',[0 1],'XTickLabel',[]);
title('Относительная ошибка решения');
subplot (3,2,6);plot (log10(Alf),log10(Vz),'k.-');
xlabel('lg(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)])
title('Квазиоптимальный выбор');
set(gcf,'Name','Тихоновская  регуляризация: выбор параметра','NumberTitle','off')
pause(0.1);
end 
[mii,nnn]=min(Dz);alfop=Alf(nnn);

figure(22);subplot (1,2,1);
plot (t(2:end),zr(2:end), '.-',t(2:end),z(2:end), 'r-');set(gca,'FontName',FntNm);
legend ('Calc' ,'Exact' , 1 ) ;
subplot (3,2,2);
plot (log10(Alf),log10(Dis), 'r.-',[-18 log10(alf0)],[log10(C*Del) log10(C*Del)], 'k-');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'XTickLabel',[]);
ylabel('llg(Невязка(\alpha))');
title('Относительная невязка уравнения');text(log10(alf0)+0.5,log10(Del),'lg(\Delta)')
subplot (3,2,4);plot (log10(Alf),Dz, 'r.-',...
   [log10(alfop) log10(alfop)],[0 1],'k'); 
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'YLim',[0 1],'XTickLabel',[]);
title('Относительная ошибка решения');
subplot (3,2,6);plot (log10(Alf),log10(Vz),'k.-');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)])
title('Квазиоптимальный выбор');
set(gcf,'Name','Решение для выбранного параметра','NumberTitle','off')

disp(' ');
disp('**** Выберите параметр регуляризации! ***** ');disp(' ');
[xa,ya]=ginput(1);[mx,ix]=min(abs(log10(Alf)-xa));alpha=Alf(ix);
[zr30,dis30,v30]=tikh_alf(KK1,ud1,h,u_k,d2u_k,alpha);
zr0=u_k*zr30;
dz0=norm(zr0(2:end)-z(2:end))/norm(z(2:end));nz0=norm(zr0);
mt0=sqrt(alpha*nz0^2+dis30^2);
disp(' ');disp('     Результаты:');disp(' ');
disp(['alpha = ' num2str(alpha) '   Относ. невязка  уравнения (L_2) = ' num2str(dis30) ]);
disp(['     Относ. ошибка решения (L_2) = ' num2str(dz0)]);

figure(22);subplot (1,2,1);
plot (t(2:end)-2,zr0(2:end), '.-',t(2:end)-2,z(2:end), 'r-');set(gca,'FontName',FntNm);
title('Регуляризованное решение \mu(t)');xlabel('Время t/t_0');
ylabel('\mu(t), ^{o}C');
legend ('Вычисленное' ,'Модельное' , 1 ) ;
subplot (3,2,2);
plot (log10(Alf),log10(Dis), 'r.-',[-18 log10(alf0)],[log10(C*Del) log10(C*Del)], 'k-',...
   log10(alpha),log10(dis30),'ob');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'XTickLabel',[]);
ylabel('lg(Невязка(\alpha))');
title('Относительная невязка');text(log10(alf0)+0.5,log10(Del),'lg(\Delta)')
subplot (3,2,4);plot (log10(Alf),Dz, 'r.-',...
   log10(alpha),dz0,'ob',log10(alfop),mii,'b.');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'YLim',[0 1],'XTickLabel',[]);
title('Относительная ошибка решения');

subplot (3,2,6);plot (log10(Alf),log10(Vz),'k.-',log10(alpha),log10(v30),'ko');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)])
xlabel('lg(\alpha)');title('Квазиоптимальный функционал');
set(gcf,'Name','Решение для выбранного параметра','NumberTitle','off')

if lcurve==1;
   disp(' ');
disp('**** Выберите параметр регуляризации по L-кривой! ***** ');disp(' ');

figure(45);subplot (1,2,2);plot(log(Dis),log(Nz),'.-',log(Dis(nnn)),log(Nz(nnn)),'.r');
set(gca,'FontName',FntNm,'YTickLabel',[],'XTickLabel',[]);
title('L-кривая');
[xx0,yy0]=ginput(1);
[mmm,iii]=min(abs(log(Dis)-xx0));alp1=Alf(iii);
[zr31,dis31,v31]=tikh_alf(KK1,ud1,h,u_k,d2u_k,alp1);
zr1=u_k*zr31;
subplot (1,2,1);
plot (t,(zr1), '.-',t,(z), 'r-');set(gca,'FontName',FntNm);
legend ('Calc' ,'Exact' , 1 ) ;

dz1=norm(zr1(2:end)-z(2:end))/norm(z(2:end));
disp(' ');disp('     Результаты:');disp(' ');
disp(['alpha = ' num2str(alp1) '   Невязка = ' num2str(dis31) '   Ошибка = ' num2str(dz1)]);
end

disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
