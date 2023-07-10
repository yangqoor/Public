% tikh_istochn


% Входные данные: AA U t=xx MU=a0 Residual=Residual_appr


KK1=AA;ud1=U';t=xx;
h=t(2)-t(1);
[zr3,dis3,v3]=tikh_alf(KK1,ud1,h,u_k,[],1e-10);Residual=dis3;
%
%if delta==0;alf0=0.3e-6;q=(0.95);elseif delta==0.01;alf0=delta/100;q=0.9;
%elseif delta==0.001;alf0=1e-5;q=0.9;end
alf0=1e-6;q=0.8;% 
%alf0=1e0;q=0.5; 

C=1.;Del=delta+Residual; %Del=delta/norm(u*h);%  alf0=1e-3 - linear
Alf=[];Dis=[];Dz=[];Nz=[];Vz=[];Disz=[];MT=[];
for kk=1:40;alf=alf0*q.^(kk-1);% (0.8)
   [zr3,dis3,v3]=tikh_alf(KK1,ud1,h,u_k,[],alf);Alf=[Alf alf];Dis=[Dis dis3];
   zr=u_k*zr3;Vz=[Vz v3];
   dz=norm(zr(2:end-1)-z(2:end-1) )/norm(z(2:end-2) );Dz=[Dz dz];nz=norm(zr);Nz=[Nz nz];
   mt=sqrt(alf*nz^2+dis3^2);MT=[MT log10(mt)];%Vz=MT;
figure(22);subplot (1,2,1);
plot (t(2:end),zr(2:end), '.-',t(2:end),z(2:end), 'r-');set(gca,'FontName',FntNm);
legend ('Приближ.' ,'Точное' , 2 ) ;
subplot (3,2,2);plot (log10(Alf),log10(Dis), 'r.-')%,...,
   %[-18 log10(alf0)],[log10(C*Del) log10(C*Del)], 'k-');
set(gca,'FontName',FntNm,'XLim',[-10 log10(alf0)],'XTickLabel',[]);
ylabel('lg(Невязка(\alpha))');%xlabel('log_{10}(\alpha)');
title('Относительная невязка');%text(log10(alf0)+0.5,log10(Del),'lg(\Delta)')
subplot (3,2,4);plot (log10(Alf),(Dz), 'r.-');%xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-10 log10(alf0)],'YLim',[0 1],'XTickLabel',[]);
title('Относительная ошибка решения');
subplot (3,2,6);plot (log10(Alf),log10(Vz),'k.-');
% hold on;plot([-18 log10(alf0)],[log10(C*Del) log10(C*Del)], 'k-');hold off
xlabel('lg(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-10 log10(alf0)]);title('Квазиоптимальный функционал');
set(gcf,'Name','Тихоновская  регуляризация: выбор параметра','NumberTitle','off')
pause(1);
end 
[mii,nnn]=min(Dz);alfop=Alf(nnn);

DDel=Del+norm(AA)*0.001*Nz/norm(U);
figure(22);subplot (1,2,1);
plot (t(2:end),zr(2:end), '.-',t(2:end),z(2:end), 'r-');set(gca,'FontName',FntNm);
legend ('Приближ.' ,'Точное' , 2 ) ;
subplot (3,2,2);
plot (log10(Alf),log10(Dis), 'r.-',log10(Alf),log10(C*DDel),'k')%,...
  %[-18 log10(alf0)],[log10(C*Del) log10(C*Del)], 'k-');
set(gca,'FontName',FntNm,'XLim',[-10 log10(alf0)],'XTickLabel',[]);
%xlabel('log_{10}(\alpha)');
ylabel('llg(Невязка(\alpha))');
title('Относительная невязка');text(log10(alf0)+0.5,log10(Del),'lg(\Delta)')
subplot (3,2,4);plot (log10(Alf),Dz, 'r.-',...
   [log10(alfop) log10(alfop)],[0 1],'k');%xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-10 log10(alf0)],'YLim',[0 1],'XTickLabel',[]);
title('Относительная ошибка решения');
subplot (3,2,6);plot (log10(Alf),log10(Vz),'k.-');
% hold on;plot([-18 log10(alf0)],[log10(C*Del) log10(C*Del)], 'k-');hold off
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-10 log10(alf0)])
title('Квазиоптимальный функционал');
set(gcf,'Name','Решение для выбранного параметра','NumberTitle','off')

disp(' ');
disp('**** Выберите параметр регуляризации на одном из графиков справа! ***** ');disp(' ');
[xa,ya]=ginput(1);[mx,ix]=min(abs(log10(Alf)-xa));alpha=Alf(ix);
%alpha=interp1(Alf,Alf,ix);
[zr30,dis30,v30]=tikh_alf(KK1,ud1,h,u_k,[],alpha);
zr0=u_k*zr30;UUU1=AA*zr0;
dz0=norm(zr0(2:end-1)-z(2:end-1) )/norm(z(2:end-1) );nz0=norm(zr0);
mt0=sqrt(alpha*nz0^2+dis30^2);%v30=log10(mt0);
disp(' ');disp('     Результаты:');disp(' ');
disp(['alpha = ' num2str(alpha) '   Относ. невязка уравнения (L_2) = ' num2str(dis30) ]);
disp(['   Относ. ошибка решения (L_2) = ' num2str(dz0)]);

figure(22);subplot (1,2,1);
plot (t(1:end),zr0(1:end), '.-',t(1:end),z(1:end), 'r-');set(gca,'FontName',FntNm);
title('Регуляризованное решение');xlabel('x');
ylabel('f(x)');
legend ('Приближ.' ,'Точное' , 2 ) ;
subplot (3,2,2);
plot (log10(Alf),log10(Dis), 'r.-',log10(Alf),log10(C*DDel),'k',...
   log10(alpha),log10(dis30),'ob');
set(gca,'FontName',FntNm,'XLim',[-10 log10(alf0)],'XTickLabel',[]);
%xlabel('log_{10}(\alpha)');
ylabel('lg(Невязка(\alpha))');
title('Относительная невязка');text(log10(alf0)+0.2,log10(Del),'lg(\Delta)')
subplot (3,2,4);plot (log10(Alf),Dz, 'r.-',...
   log10(alpha),dz0,'ob',log10(alfop),mii,'b.');
%xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-10 log10(alf0)],'YLim',[0 1],'XTickLabel',[]);
title('Относительная ошибка решения');
subplot (3,2,6);plot (log10(Alf),log10(Vz),'k.-',log10(alpha),log10(v30),'ko');
% hold on;plot([-18 log10(alf0)],[log10(C*Del) log10(C*Del)], 'k-');hold off
set(gca,'FontName',FntNm,'XLim',[-10 log10(alf0)])
xlabel('lg(\alpha)');title('Квазиоптимальный функционал');
set(gcf,'Name','Решение для выбранного параметра (ОПН)','NumberTitle','off')
pause(1)

figure(331);subplot (1,2,1);
plot (t(1:end),zr0(1:end), '.-',t(1:end),z(1:end), 'r-');set(gca,'FontName',FntNm);
title('Регуляризованное решение');xlabel('x');
ylabel('f(x)');
legend ('Приближ.' ,'Точное' , 2 ) ;
subplot (1,2,2);
plot (t(1:end),UUU1, '.-',t(1:end),U0(1:end), 'r-');set(gca,'FontName',FntNm);
title('Переопределение');xlabel('x');ylabel('u(x)');
legend ('Приближ.' ,'Точное' , 2 ) ;
set(gcf,'Name','Результаты для выбранного параметра (ОПН)','NumberTitle','off');t1=t;
pause(1)

if exist('initmesh');
a=repmat(zr0',M,1);
[p,e,t]=initmesh('pryamg');[p,e,t]=refinemesh('pryamg',p,e,t);
[p,e,t]=refinemesh('pryamg',p,e,t);[p,e,t]=refinemesh('pryamg',p,e,t);
u=assempde('prya',p,e,t,1,0,'istok1');% Гр. условия, ур-ние Лапласа, источник
figure(134);pdeplot(p,e,t,'xydata',u);hold on;
plot(xx,yy(NN)*ones(size(xx)),'r');hold off;set(gca,'FontName',FntNm)
set(gca,'YTickLabel',char(num2str([0:0.1:0.8]')))
title('Температура для найденного источника');xlabel('x');ylabel('y');
set(gcf,'Name','Температура (ОПН) ','NumberTitle','off')
end
pause(1)

if lcurve==1;
   disp(' ');
disp('**** Выберите параметр регуляризации по L-кривой! ***** ');disp(' ');

[xi]=kriv(Dis,Nz);
figure(45);subplot (1,2,2);plot(log(Dis),log(Nz),'.-',log(Dis(xi)),log(Nz(xi)),'.r');
set(gca,'FontName',FntNm,'YTickLabel',[],'XTickLabel',[]);;axis equal
title('L-кривая');
[xx0,yy0]=ginput(1);
[mmm,iii]=min(abs(log(Dis)-xx0));alp1=Alf(iii);
[zr31,dis31,v31]=tikh_alf(KK1,ud1,h,u_k,[],alp1);
zr1=u_k*zr31;
subplot (1,2,1);
plot (t1,(zr1), '.-',t1,(z), 'r-');set(gca,'FontName',FntNm);
legend ('Приближ.' ,'Точное' , 2 ) ;
set(gcf,'Name','Результаты по L-кривой','NumberTitle','off')

dz1=norm(zr1(1:end)-z(1:end) )/norm(z(1:end) );
disp(' ');disp('     Результаты:');disp(' ');
disp(['alpha = ' num2str(alp1) '   Относ. невязка уравнения (L_2) = ' num2str(dis31) ]);
disp([ '   Относ. ошибка решения (L_2) = ' num2str(dz1)]);
disp(' ');
end

%disp(' ');disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Конец %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
