% L_counterexample

% График L-кривой для контрпримера (с.55)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

z=[];d=[];AL=[];alf0=1500;
for kk=1:125;alf=alf0*0.9^kk;z=[z 1/(alf+1)];d=[d abs(1/(alf+1)-1)];
AL=[AL alf];end
[xxa,yya]=kriv(log10(d),log10(z));
figure(1);plot(-log(d),-log(z),'.-',-log(d(xxa)),-log(z(xxa)),'or')
axis equal;set(gca,'XLim',[0 6],'YLim',[0 7]);text(1,1,['\alpha_L = 1']);
set(gca,'FontName',FntNm);
title(' L-кривая для контрпримера');xlabel('-ln(||Az^{\alpha}-u||)');
ylabel('-ln(||z^{\alpha}||)');
alfa_L=AL(xxa)