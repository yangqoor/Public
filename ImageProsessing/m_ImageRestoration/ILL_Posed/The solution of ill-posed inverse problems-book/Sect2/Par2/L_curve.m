%  L_curve

%  ������� ���� Az=u � ����������� �������� ������������� �������� (���������� 
%  ����������� �������������).
%  ������� �������� � ����� � ������� ������������ ������, � ������ ����������� ���������� 
%  �� ������������ ���������� ������� L-������.
%  ��������� � ������������ ������������ ��������� �� ����������� �������� �������.

clear all;close all
warning off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  ������, ����� ����� L-������ ���� ������ ���������. 
%  ��� ���� ���������� ������� ������� (� ������� pinv �������) �������� ������.

BB=[];CC=[];DD=[];mu=0.4;A=diag(ones(1,20))+diag(ones(1,19),1);u=ones(20,1);
z0=pinv(A)*u;nr=norm(z0);%mu_max=2/norm(A'*A)
s1='   ������� �����';s2='   ����� �����';s3='   ����� ����������� ����������';

disp(' ');disp(' ���������� ������ L-������ ��� �������� ��������');
disp('     ��� ������� ���� ������������� ��������');disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');
disp('      ������� ����� ������� ��� ������ ��������� ������� ����. ');disp(' ');pause
figure(22);A0=zeros(size(A));A0(20,1)=1;spy(A);
hold on;spy(A0,'r');hold off;title('');
set(gcf,'Name',' ��������� ������ � ������������ �������','Number','off');
disp(['      cond(A) = ' num2str(cond(A))]);disp(' ');
disp('-----------------------------------------------------------------------------');
disp(' ');
met=input('   ������� ����� ������ ������� (1 - �������, 2 - �����, 3 - ������. ���������)  ');
% ������� ������: 1 - �������, 2 - �����, 3 - ����� ����������� ����������
% �� ��������� - ������� �����.
disp(' ');if isempty(met);met=1;end
disp('-----------------------------------------------------------------------------');

if met==2;disp(' ');disp(s2);
elseif met==1; disp(' ');disp(s1);elseif met==3;
disp(' ');disp(s3);end

for kh=1:7;h=10^(-kh);disp(' ');
   disp('-----------------------------------------------------------------------------');
   disp(' ');
  disp([' ������� <����> ��� ������� ���� � ������� ����������� h = ' num2str(h)]);pause;
  A(20,1)=h;AA=A'*A;w=A'*u;z=zeros(20,1);B=[];
  %
if met==2;sss=s2;  
% ����� �����
for kk=1:1000;z1=z-mu*A'*(A*z-u);B=[B z1];bbe(kk)=norm(A*z1-u);gga(kk)=norm(z1);z=z1;
end;
elseif met==1;sss=s1; 
% ������� �����  
  for kk=1:1000;mu=1;z1=inv(eye(20)+mu*AA)*(z+mu*w);B=[B z1];bbe(kk)=norm(A*z1-u);
    gga(kk)=norm(z1);z=z1;end; 
elseif met==3;sss=s3;
 for kk=1:40;[xx,flag]=pcg(AA,w,[],kk);B=[B xx];bbe(kk)=norm(A*xx-u);gga(kk)=norm(xx);end
else end
ddb=diff(bbe);ddg=diff(gga);ij=find(ddb<0);
d1=ddg(ij)./ddb(ij);d1=[d1 d1(end)];
d2=diff(d1)./ddb(ij);d2=[d2 d2(end)];
r=((1+d1.^2).^(3/2))./abs(d2);if met==3;jk=find((~isinf(r)));rr=r(jk);r=rr(rr>1e-5);else end
[aa,ii]=min(r);
figure(2);subplot(1,2,1);
plot(bbe,gga,'.-',bbe(ii),gga(ii),'or',bbe,nr*ones(size(bbe)),'k');
set(gca,'FontName',FntNm,'FontSize',9)
text(0.5,0.98*nr,'\gamma=||z_{exact}||');title(' L-������');
xlabel(' \beta_n');ylabel(' \gamma_n');
hhp=legend('L-������','��������� ����� ��������',3);set(hhp,'Position',[0.180 0.516 0.323 0.101]);
subplot(1,2,2);plot(r,'.-');set(gca,'YLim',[0 1],'FontName',FntNm)
title(' ������ ��������');xlabel(' ����� ��������')
hold on;plot(ii,r(ii),'ro');hold off
set(gcf,'Name','L-������','Number','off');
BB=[BB B(:,ii)];CC=[CC pinv(A)*u];
jj=min(find(bbe-h*gga<=0));if isempty(jj);jj=1000;end%  ����� ����� �������� �� ���
DD=[DD B(:,jj)];

disp('-----------------------------------------------------------------------------');
disp(' ������� ����� ������� ��� ������ �������!');pause;

mm=3;
figure(3);subplot(mm,1,1);plot(z0,'.-');hold on;%plot(BB(:,2),'m');plot(BB(:,4),'k');
plot(BB(:,kh),'r');hold off;set(gca,'XTickLabel',[ ],'FontName',FntNm);
hhhh=text(7,1.5,sss);set(hhhh,'FontName',FntNm)
title(['������� ����. ������� �������� �� L-������. ������ ������� : h=' num2str(h)]);
hp=legend('������','L-������',2);set(hp,'Position',[0.0485 0.684 0.207 0.101]);
subplot(mm,1,3);plot(z0,'.-');hold on;%plot(CC(:,2),'m');plot(CC(:,4),'k');
plot(CC(:,kh),'r');hold off;set(gca,'FontName',FntNm)
title(' ��������� � �������������� ������� Pinv');hp=legend('������','Pinv',2);
set(hp,'Position',[0.0485 0.049 0.207 0.101]);
subplot(mm,1,2);plot(z0,'.-');hold on;%plot(DD(:,2),'g');plot(DD(:,4),'k');
plot(DD(:,kh),'r');hold off;set(gca,'XTickLabel',[ ],'FontName',FntNm);
hhhh=text(7,1.5,sss);set(hhhh,'FontName',FntNm)
title(' ������� �������� �� ���');hp=legend('������','���',2);
set(hp,'Position',[0.0485 0.384 0.207 0.101]);
set(gcf,'Name','������� �������� �� L-������ � ���','Number','off');

end
%

disp('-------------------------------- ����� --------------------------------------');

