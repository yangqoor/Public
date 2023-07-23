function grchoi(Alf,gdis,gsmu,alf_opn,alf_opsf,Dis,Tf,C,mu,Delta,H,Dz);

figure(51);plot(log10(Alf),gdis, 'r.-',log10(Alf),zeros(size(Alf)),'k-',... 
   log10(alf_opn),0,'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName','Arial Cyr','XLim',[log10(min(Alf)) log10(max(Alf))],'YLim',[-0.2 0.2]);
title('ном');

figure(52);plot(log10(Alf),gsmu, 'r.-',log10(Alf),zeros(size(Alf)),'k-',... 
   log10(alf_opsf),0,'bo');
xlabel('log_{10}(\alpha)');
set(gca,'FontName','Arial Cyr','XLim',[log10(min(Alf)) log10(max(Alf))],'YLim',[-0.025 0.025]);
title('ноят');

return
figure(53);plot(log10(Alf),Dis, 'r-',log10(Alf),0*mu+Delta+H*sqrt(Dz),'k-',... 
   [log10(alf_opn) log10(alf_opn)],[0 max(Delta+H*sqrt(Dz))],'b');
xlabel('log_{10}(\alpha)');
set(gca,'FontName','Arial Cyr','XLim',[log10(min(Alf)) log10(max(Alf))]);
%,'YLim',[-0.025 0.025]);
title('ном');

figure(54);
plot(log10(Alf),Tf, 'r-',log10(Alf),C*(mu+Delta+H*sqrt(Dz)).^2+(C-1)*mu^2,'k-',... 
   [log10(alf_opsf) log10(alf_opsf)],[0 max(C*(mu+Delta+H*sqrt(Dz)).^2+(C-1)*mu^2)],'b');
xlabel('log_{10}(\alpha)');
set(gca,'FontName','Arial Cyr','XLim',[log10(min(Alf)) log10(max(Alf))]);
%,'YLim',[-0.025 0.025]);
title('ноят');

