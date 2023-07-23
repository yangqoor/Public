% Tikh_reg_w

C=1.1;q=0.6;NN=25;CC=1.7;CC=1.2;
% Вычисление функций для выбора параметра регуляризации
[Alf,Opt,Dis,Nz,VV,Tf,Dz,Ur]=func_calc(AA,U,h,h,deltaA,delta,C,q,NN,a0',reg);

Del=delta*norm(U)+deltaA*norm(AA)*Nz*norm(U);
% Выбор параметра по критериям:
[xxa,yya]=kriv(log10(Dis),log10(Nz));%xxa=xxa+1;
ix=min(find(Dis<=CC*Del));iix=min(find(Tf<=C*Del.^2));
[vm,iv]=min(VV);
[um,iu]=min(Ur);
[zm,iz]=min(Opt);
if isempty(ix);ix=iz;end;if isempty(iix);iix=iz;end;if delta == 0;iu=iz;end

% Графическое отображение правил выбора параметра:
figure(22);
subplot (2,2,1);plot(log10(Alf),Dis, 'r.-',log10(Alf),CC*Del,'k-',... %[-18 log10(max(Alf))],[Del Del], 'k-',...
   log10(Alf(ix)),Dis(ix),'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName','Arial Cyr','XLim',[-18 log10(max(Alf))],'YLim',[0 0.2]);
title('ОПН');text(-1,delta,'\delta')
legend ('||Az^{\alpha}-u||','\Delta (\delta,h,z^{\alpha})',['\alpha=' num2str(Alf(ix))],2 )

subplot (2,2,2);plot(log10(Alf),Opt, 'r.-',log10(Alf),VV/max(VV),'-b',...
   log10(Alf(iz)),Opt(iz),'ro',log10(Alf(iv)),VV(iv)/max(VV),'bo',...
   log10(Alf),Ur/max(Ur),'.-k',log10(Alf(iu)),Ur(iu)/max(Ur),'ok');%
xlabel('log_{10}(\alpha)');
set(gca,'FontName','Arial Cyr','XLim',[-18 log10(max(Alf))],'YLim',[0 1]);
title('Oптим. (квазиоп.) выбор ');
legend ('~||z^{\alpha}-z_{exact}||' ,'~||\alpha dz^{\alpha}/d\alpha||',...
   ['\alpha=' num2str(Alf(iz))] , 2 )

subplot (2,2,3);plot(log10(Dis),log10(Nz),'.-',log10(Dis(xxa)),log10(Nz(xxa)),'ro',...
   log10(Dis(xxa)),log10(Nz(xxa)),'r.');
set(gca,'FontName','Arial Cyr');legend('L-кривая',['\alpha=' num2str(Alf(xxa))]);
xlabel('log_{10}(||Az^{\alpha}-u||)');
ylabel('log_{10}(||z^{\alpha}||)');

subplot (2,2,4);plot(log10(Alf),Tf, 'r.-',log10(Alf),C*Del.^2,'k-',... %[-18 log10(max(Alf))],[C*Del^2 C*Del^2], 'k-',...
   log10(Alf(iix)),Tf(iix),'bo');
 xlabel('log_{10}(\alpha)');
if zadan==1;C=1.1;else C=1.4;;end
set(gca,'FontName','Arial Cyr','XLim',[-18 log10(max(Alf))],'YLim',[0 0.025]);
text(-1,delta^2,'C\delta^2');
legend ('\alpha||z^{\alpha}||^2+||Az^{\alpha}-u||^2',...
   'C\Delta^2 (\delta,h,z^{\alpha})',['\alpha=' num2str(Alf(iix))],2 )
set(gcf,'Name','Выбор параметра','NumberTitle','off','Position',[435 237 560 420])
pause(1);
% Сравнение качества решений
[zrd,disd]=Tikh_alf11(AA,U,h,delta,Alf(ix),reg);
[zrk,disk]=Tikh_alf11(AA,U,h,delta,Alf(iu),reg);
[zrl,disl]=Tikh_alf11(AA,U,h,delta,Alf(xxa),reg);
[zrs,diss]=Tikh_alf11(AA,U,h,delta,Alf(iix),reg);
%

z=a0';
erd=norm(zrd-z)/norm(z);erk=norm(zrk-z)/norm(z);
erl=norm(zrl-z)/norm(z);ers=norm(zrs-z)/norm(z);ero=[];%ero=norm(zro-z)/norm(z);
[nmm,ind]=min([erd erk erl ers ero]);

% Графическое сравнение качества решений
figure(23);plot(s,a0','k',s,zrd,'.-',s,zrk,'.-',s,zrl,'.-',s,zrs,'.-');%,t,zro,'.-')
set(gca,'FontName','Arial Cyr','YLim',[0.9*min(z) 1.1*max(z)]);
xlabel('t');ylabel('z(t), z^{\alpha}(t)');
h7=legend('точное решение','обобщ. невязка','модиф. кв.опт. выбор','L-кривая','сглаж. функционал',1);
set(h7,'Position', [0.635952 0.788984 0.35 0.201095]);
hh=text(1,11,'Отн. ошибки в L_2');set(hh,'FontName','Arial Cyr');
hh=text(1,10.5,['об.нев: ' num2str(erd)]);set(hh,'FontName','Arial Cyr');
hh=text(1,10, ['кв.опт:  ' num2str(erk)]);set(hh,'FontName','Arial Cyr');
hh=text(1,9.5,['L-крив.: ' num2str(erl)]);set(hh,'FontName','Arial Cyr');
hh=text(1,9, ['сгл.ф-л: ' num2str(ers)]);set(hh,'FontName','Arial Cyr');
%text(-0.6,0.05,num2str(ero));
set(gcf,'Name','Сравнение решений','NumberTitle','off','Position',[435 237 560 420])

% Сравнение вариаций
Var_error_td=Var1(zrd'-a0)/Var1(a0);
Var_error_tk=Var1(zrk'-a0)/Var1(a0);
Var_error_tl=Var1(zrl'-a0)/Var1(a0);
Var_error_ts=Var1(zrs'-a0)/Var1(a0);
%Del_L2_w2=norm(zr30'-a0)/norm(a0)
%V_1_w2=Var1(diff(zr30)'./hsf-da0)/Var1(da0)
Residual=disk;
Error=norm(zrd'-a0,inf)/norm(a0,inf);
disp(['   alpha = ' num2str(Alf(ix))]);
disp(['   Residual = ' num2str(Residual) '   C_error = ' num2str(Error)]);

Var_error_tikh=Var_error_td

