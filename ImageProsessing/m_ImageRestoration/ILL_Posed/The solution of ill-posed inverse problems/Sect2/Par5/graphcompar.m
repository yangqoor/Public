function graphcompar(t,z,zrd,zrk,zrl,zrs,erd,erk,erl,ers,NF1,sss,Nom);
% ��� Comp_L_solut
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mst=0.5*(max(z)-min(z));
figure(NF1);plot(t,z,'k',t,zrd,'.-',t,zrl,'.-',t,zrs,'.-');%,t,zro,'.-')
  hold on;plot(t,zrk,'m.-');hold off;
set(gca,'FontName',FntNm);
xlabel('t');ylabel('z(t), z^{\alpha}(t)');
  h7=legend('������ ���.','����. �������','L-������','�����. �-�','���������. �����',1);
set(h7,'Position', [0.635952 0.788984 0.35 0.201095]);
hh=text(t(40),mst,'���. ������');set(hh,'FontName',FntNm);
hh=text(t(40),2*mst/3,['����.���: ' num2str(erd)]);set(hh,'FontName',FntNm);
hh=text(t(40),2*mst/4,['L-������: ' num2str(erl)]);set(hh,'FontName',FntNm);
hh=text(t(40),2*mst/5, ['�����.�-�: ' num2str(ers)]);set(hh,'FontName',FntNm);
  hh=text(t(40),2*mst/7, ['�����.���:  ' num2str(erk)]);
  set(hh,'FontName',FntNm);

set(gcf,'Name',['��������� ������� ' sss],'NumberTitle','off')
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
