function [zre,alfa,sr]=best_alfa(t,KK1,ud1,z,C,delta,h,show_comp)

alf0=1000*delta*norm(KK1)/(norm(ud1)-delta*norm(ud1));Del=delta;%Del=delta*norm(u*h);
Alf=[];Dis=[];Dz=[];Nz=[];VV=[];Tf=[];
for kk=1:15;alf=alf0*(0.2).^(kk-1);
   [zr3,dis3,v3]=Tikh_alf1(KK1,ud1,h,delta,alf);Alf=[Alf alf];Dis=[Dis dis3];
   dz=norm(zr3-z)/norm(z);Dz=[Dz dz];nz=norm(zr3);Nz=[Nz nz];VV=[VV v3];
   tf=(alf*norm(zr3)^2+(dis3*norm(ud1))^2)/norm(ud1)^2;
   Tf=[Tf tf];
end   
%
[xxa,yya]=kriv2(log10(Dis),log10(Nz));%xxa=xxa+1;
ix=min(find(Dis<=Del));iix=min(find(Tf<=C*Del^2));
[vm,iv]=min(VV);
[zm,iz]=min(Dz);

% Набор результатов
figure(22);
subplot (2,2,1);plot(log10(Alf),Dis, 'r.-',[-18 log10(alf0)],[Del Del], 'k-',...
   log10(Alf(ix)),Dis(ix),'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName','Arial Cyr','XLim',[-18 log10(alf0)]);
title('Относительная невязка');text(-1,delta,'\delta')
legend ('||Az^{\alpha}-u||/||u||=\delta',2 )
subplot (2,2,2);plot (log10(Alf),Dz, 'r.-',log10(Alf),VV/max(VV),'.-b',...
   log10(Alf(iv)),VV(iv),'bo',log10(Alf(iz)),Dz(iz),'ro');
xlabel('log_{10}(\alpha)');
set(gca,'FontName','Arial Cyr','XLim',[-18 log10(alf0)],'YLim',[0 1]);
title('Относительная ошибка решения ');
legend ('~||z^{\alpha}-z_{exact}||' ,'~||\alpha dz^{\alpha}/d\alpha||' , 2 )
subplot (2,2,3);plot(log10(Dis),log10(Nz),'.-',log10(Dis(xxa)),log10(Nz(xxa)),'ro',...
   log10(Dis(xxa)),log10(Nz(xxa)),'r.');
set(gca,'FontName','Arial Cyr');legend('L-кривая',['\alpha=' num2str(Alf(xxa))]);
xlabel('log_{10}(||Az^{\alpha}-u||)');
ylabel('log_{10}(||z^{\alpha}||)');
subplot (2,2,4);plot(log10(Alf),Tf, 'r.-',[-18 log10(alf0)],[C*Del^2 C*Del^2], 'k-',...
   log10(Alf(iix)),Tf(iix),'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName','Arial Cyr','XLim',[-18 log10(alf0)]);
text(-1,delta^2,'C\delta^2');
legend ('(\alpha||z^{\alpha}||^2+||Az^{\alpha}-u||^2)/||u||^2=C\delta^2',2 )
set(gcf,'Name','Выбор параметра','NumberTitle','off')

% Сравнение качества решений
[zrd,dis1,v1]=Tikh_alf1(KK1,ud1,h,delta,Alf(ix));
[zrk,dis1,v1]=Tikh_alf1(KK1,ud1,h,delta,Alf(iv));
[zrl,dis1,v1]=Tikh_alf1(KK1,ud1,h,delta,Alf(xxa));
[zrs,dis1,v1]=Tikh_alf1(KK1,ud1,h,delta,Alf(iix));
%[zro,dis1,v1]=Tikh_alf1(KK1,ud1,h,delta,Alf(iz));

erd=norm(zrd-z)/norm(z);erk=norm(zrk-z)/norm(z);
erl=norm(zrl-z)/norm(z);ers=norm(zrs-z)/norm(z);ero=[];%ero=norm(zro-z)/norm(z);
[nmm,ind]=min([erd erk erl ers ero]);

if ~isequal(show_comp,0);
figure(23);plot(t,z,'k',t,zrd,'.-',t,zrk,'.-',t,zrl,'.-',t,zrs,'.-');%,t,zro,'.-')
set(gca,'FontName','Arial Cyr');xlabel('t');ylabel('z(t), z^{\alpha}(t)');
legend('точное реш.','невязка','квазиопт. ф-л','L-кривая','сглаж. ф-л',2)
hh=text(-0.6,0.3,'Отн. ошибки');set(hh,'FontName','Arial Cyr');
text(-0.6,0.25,num2str(erd));text(-0.6,0.2,num2str(erk));
text(-0.6,0.15,num2str(erl));text(-0.6,0.1,num2str(ers));%text(-0.6,0.05,num2str(ero));
set(gcf,'Name','Сравнение решений','NumberTitle','off')
end

if ind==1;zre=zrd;alfa=Alf(ix);sr='невязка';elseif ind==2;zre=zrk;alfa=Alf(iv);...
      sr='квазиопт. ф-л';elseif ind==3;zre=zrl;alfa=Alf(xxa);sr='L-кривая';...
   elseif ind==4;zre=zrs;alfa=Alf(iix);sr='сглаж. ф-л';
%else ind==5;zre=zro;alfa=Alf(iz);sr='оптим.';
end

