%  Entropy

% ����� ������������ �������� ��� ������� ������ ������������ �� ������ �������������
% ������� (�.149).
% 
clear all;close all

if ~exist('fmincon');disp(' ');
  disp('  ��������! ������������ �����������, �.�. �� ���� ���');
  disp('  �� ���������� ��������� ������� - Optimization Toolbox.');return;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FntNm='Arial Cyr';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vvv=ver('MATLAB');nmver=str2num(vvv.Version);if nmver>6;
warning('off','MATLAB:dispatcher:InexactMatch');end

disp(' ');disp(' ����� ������������ �������� ��� ������� ������ ������������ (�.149)');
disp('    �������� ������������ ��������� ���������� 1-�� ���� � ����� ��������');

n=121;h=1/(n-1);x=[0:h:1];[xs,ys]=meshgrid(x,x);
A=h./(1+100*(xs-ys).^2);% ��� n=100 cond(A)=1.2345e+013
A(:,1)=0.5*A(:,1);A(:,n)=0.5*A(:,n);
z0=x.^2;% ��������� �������
   b1=1/100+1/100*x.*log(101+100*x.^2-200*x)+1/1000*atan(10*x-10)- ...
      1/10*atan(10*x-10).*x.^2-1/100*x.*log(1+100*x.^2)- ...
      1/1000*atan(10*x)+1/10*atan(10*x).*x.^2;% ��������� ������ �����
del=0.01;
rn=randn(size(b1));nrn=norm(rn);b=b1+del*norm(b1)*rn/nrn;       
    d=1.1;% ��������� ������� �������
    r=-26;% ��������� ��������; 
    z1=zeros(n,1);% ��������� �����������
   z1=x';% ��������� �����������
%clear options;options(14)=50;options(1)=1;
%tic;z1=constr('fun5',z1,options,1e-8*ones(n,1),d*ones(n,1),'grfun5',A,b',r);toc
warning off
options=optimset('Display','off','GradObj','on','GradConstr','on','MaxIter',50);%'iter'
warning off;h00 = waitbar(0,'Wait a minute!');waitbar(1,h00)
tic;z1=fmincon('fun6',z1,[],[],[],[],1e-8*ones(n,1),d*ones(n,1),'grfun6',options,A,b',r);toc
close(h00)

figure(3);plot(x,z0,x,z1,'r');set(gca,'FontName',FntNm);
title('����� ������������ ��� ������������ �������� ');
xlabel('x');ylabel('�������');legend('������ �������','�����������',2)

Discrepancy=norm(A*z1-b')/norm(b);Entr=-sum(z0.*log(z0+eps));Entr1=-sum(z1.*log(z1));
error=norm(z0-z1')/norm(z0);

disp(' ');disp('     ������ � ����������.');disp(' ');
disp([' �������� ������� ������� = ' num2str(Entr)]);
disp([' ��������� ������ �������� = ' num2str(-r)]);
disp([' ������������� ������ ������ = ' num2str(del)]);
disp([' ������� ������������� ������� = ' num2str(Discrepancy)]);
disp([' ������������� ������ ������� (� L_2)= ' num2str(error)]);
disp([' �������� ������������� ������� = ' num2str(Entr1)]);
disp(' ');

