function graphchoise(Alf,Dis,Del,ix,delta,Opt,VV,iz,iv,Ur,iu,Nz,xxa,Tf,C,iix,NF,sss,Nom);
% для Comp_L_solutions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(NF);
%  ОПН
subplot (2,2,1);plot(log10(Alf),Dis, 'r.-',log10(Alf),Del,'k-',... %[-18 log10(max(Alf))],[Del Del], 'k-',...
   log10(Alf(ix)),Dis(ix),'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(max(Alf))],'YLim',[0 0.2]);
title('ОПН');
legend ('||Az^{\alpha}-u||','\pi(\alpha)=\delta+h||z^{\alpha}||',['\alpha=' num2str(Alf(ix))],2 )

% Оптимальный и псевдооптимальный выбор
subplot (2,2,2);cla;
plot(log10(Alf),Opt,'r.-',log10(Alf),VV/max(VV),'-b',log10(Alf),Del/max(VV),'-k',...
  log10(Alf(iz)),Opt(iz),'ro',log10(Alf(iv)),VV(iv)/max(VV),'bo');%
%xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'FontSize',8,'XLim',[-18 log10(max(Alf))],'YLim',[0 1]);
title('Оптим. и псевдоопт. выбор ');
s1=['\alpha_{op}=' num2str(Alf(iz))];s2=['\alpha_{po}=' num2str(Alf(iv))];
s3='||z^{\alpha}-z_{exct}||';s4='\zeta(\alpha)';s5='K\pi(\alpha)';
hh=legend (s3,s4,s5,s1,s2,2);set(hh,'Position',[0.49 0.647 0.25 0.25 ]);

% Выбор по L-кривой
subplot (2,2,3);plot(log10(Dis),log10(Nz),'.-',log10(Dis(xxa)),log10(Nz(xxa)),'ro',...
   log10(Dis(xxa)),log10(Nz(xxa)),'r.');axis equal;
set(gca,'FontName',FntNm);legend('L-кривая',['\alpha=' num2str(Alf(xxa))]);
xlabel('log_{10}(||Az^{\alpha}-u||)');
ylabel('log_{10}(||z^{\alpha}||)');

%  ОПСФ
subplot (2,2,4);plot(log10(Alf),Tf, 'r.-',log10(Alf),C*Del.^2,'k-',... 
  log10(Alf(iix)),Tf(iix),'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(max(Alf))],'YLim',[0 0.025]);
title('ОПСФ');
%
legend ('\alpha||z^{\alpha}||^2+||Az^{\alpha}-u||^2',...
   'C\pi (\alpha)^2 ',['\alpha=' num2str(Alf(iix))],2 )
set(gcf,'Name',['Выбор параметра' sss],'NumberTitle','off')
