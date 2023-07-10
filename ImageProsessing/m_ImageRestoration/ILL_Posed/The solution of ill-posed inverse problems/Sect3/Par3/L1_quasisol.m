%   L1_quasisol

% ����� ������������ �� ������ L[0,1] � �������� �����������������

if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');disp('    ���������� ������ ������������ �� ������ L[0,1] (�.150).')
disp(' ');
disp('    �������� ������������ ��������� ���������� 1-�� ���� � ����� ��������');


n=60;h=1/(n-1);x=[0:h:1];[xs,ys]=meshgrid(x,x);

A=h./(1+100*(xs-ys).^2);% ��������� ����
A(:,1)=0.5*A(:,1);A(:,n)=0.5*A(:,n);

z0=x.^2;% ��������� �������
   b1=1/100+1/100*x.*log(101+100*x.^2-200*x)+1/1000*atan(10*x-10)- ...
      1/10*atan(10*x-10).*x.^2-1/100*x.*log(1+100*x.^2)- ...
      1/1000*atan(10*x)+1/10*atan(10*x).*x.^2;% ������ ������ �����
    
del=0.01;% ���������� ������
rn=randn(size(b1));nrn=norm(rn);b=b1+del*norm(b1)*rn/nrn;

m=2*n; 
c=0.5/h;% ��������� ������ ����� � L_1
d=1.1;% ��������� ������ ������� ������

B=[A -A ];% �������������� �������
z1=zeros(m,1);% ��������� �����������

%    ����� ������������
%clear options;options(14)=30;options(1)=1;tic
%z1=constr('fun3',z1,options,zeros(m,1),d*ones(m,1),'grfun3',B,b',c);toc
warning off;h00 = waitbar(0,'Wait a minute!');waitbar(1,h00)
options=optimset('Display','off','GradObj','on','GradConstr','on',...
  'MaxIter',50,'Diagnostics','off');% 'Display','iter','off'
tic;z1=fmincon('fun4',z1,[],[],[],[],zeros(m,1),d*ones(m,1),'grfun4',options,B,b',c);toc
close(h00)

zz=(z1(1:n)-z1(n+1:2*n));% �������� ��������������; 

figure(1);plot(x,z0,x,zz,'r.');set(gca,'FontName',FntNm);
title('����� ������������ �� ������ ������� L_1');
xlabel('x');ylabel('�������');legend('������ �������','�����������',2)
Discrep=norm(B*z1-b')/norm(b);
error=norm(z0-zz',1)/norm(z0,1);
var=sum(abs((zz)))*h;
disp(' ');disp('     ������ � ����������.');disp(' ');
disp([' ����� � L_1 ������� ������� = ' num2str(1/3)]);
disp([' ��������� ������ ����� � L_1 = ' num2str(c*h)]);
disp([' ������������� ������ ������ = ' num2str(del)]);
disp([' ������� ������������� ������� = ' num2str(Discrep)]);
disp([' ������������� ������ ������� (� L_1)= ' num2str(error)]);
disp([' ����� � L_1 ������������� ������� = ' num2str(var)]);
disp(' ');


