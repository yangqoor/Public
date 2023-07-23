% tikh_solut_staz_teplo

% ���������� ������ ������������� ��� �������� ������ ������������� ������������ 
% ��������. ������������ � Inv_flux. 

KK1=AA;ud1=U-Bg;
z=a0';t=sf;h=mean(diff(ss));
%
alf0=100;Del=delta;
Alf=[];Dis=[];Dz=[];Nz=[];W=[];
for kk=1:23;alf=alf0*(0.2).^(kk-1);
   [zr3,dis3]=Tikh_alf(KK1,ud1,h,delta,alf);Alf=[Alf alf];Dis=[Dis dis3];
   dz=norm(zr3-z)/norm(z);Dz=[Dz dz];nz=norm(zr3);Nz=[Nz nz];
   end 
figure(22);subplot (1,2,1);
plot (t,flipud(zr3), '.-',t,flipud(z), 'r-');set(gca,'FontName',FntNm);
legend ('Calc' ,'Exact' , 1 ) ;

ix=min(find(Dis<Del));

subplot (3,2,2);
plot (log10(Alf),log10(Dis), 'r.-',[-18 log10(alf0)],[log10(Del) log10(Del)],...
  'k-',log10(Alf(ix)),log10(Dis(ix)),'or');
ylabel('lg[�������(\alpha)]');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)]);
title('������������� ������� ���������');text(-1,log10(delta),'lg(\delta)')

subplot (3,2,6);plot (log10(Alf),(Dz), 'r.-');xlabel('lg(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'YLim',[0 1]);
title('������������� ������ �������');
set(gcf,'Name','�����������  �������������: ����� ���������','NumberTitle','off')
  
disp(' ');
disp('**** �������� �������� �������������! ***** ');disp(' ');
[xa,ya]=ginput(1);[mx,ix]=min(abs(log10(Alf)-xa));alpha=Alf(ix);
[zr30,dis30]=Tikh_alf(KK1,ud1,h,delta,alpha);dz0=norm(zr30-z)/norm(z);
disp('');
disp(['alpha = ' num2str(alpha) '   �������. ������� ��������� (L_2)= ' num2str(dis30)]);
disp(['   �������. ������ ������� (L_2) = ' num2str(dz0)]);disp(' ');

figure(22);subplot (1,2,1);
plot (t,flipud(zr30), '.-',t,flipud(z), 'r-');set(gca,'FontName',FntNm);
title('����� �� �����. �����������')
legend ('Calc' ,'Exact' , 1 ) ;
subplot (3,2,2);
plot (log10(Alf),log10(Dis), 'r.-',[-18 log10(alf0)],[log10(Del) log10(Del)], 'k-',...
   log10(alpha),log10(dis30),'ob');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)]);%xlabel('log_{10}(\alpha)');
ylabel('lg[�������(\alpha)]');
title('������������� �������');text(-1,log10(delta),'lg(\delta)')

subplot (3,2,6);plot (log10(Alf),Dz, 'r.-',log10(alpha),dz0,'ob');
xlabel('lg(\alpha)');
set(gca,'FontName',FntNm,'XLim',[-18 log10(alf0)],'YLim',[0 1]);
title('������������� ������ �������');
set(gcf,'Name','������� ��� ���������� ���������','NumberTitle','off')

UUV=AA*zr30+Bg;
figure(23);subplot (1,2,1);
plot (t,flipud(zr30), '.-',t,flipud(z), 'r-');set(gca,'FontName',FntNm);
title('����� �� �����. �����������')
legend ('Calc' ,'Exact' , 1 ) ;
subplot(1,2,2);plot(ss,U0,'r',ss,UUV','.');set(gca,'FontName',FntNm);
title('����� �� �����. �����������')
legend ('Exact' ,'Calc' , 1 ) ;
set(gcf,'Name','������� ��� ���������� alpha','NumberTitle','off')

if tmp_riss>0;
disp('   ������� ����� �������, ����� ���������� ����������� �������������');
disp('   ����������� � �������� ������� � ����!');disp(' ');pause

a=zr30';gg=1;sol3(10);end


