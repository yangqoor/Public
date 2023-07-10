function [B,IB,rapr]=mpm_inv1(AA,hh)
%   ���������� ������� ��� � �������� ������� ��� ����� ��������� (B,B1,IB,IB1). 
%   ������ ����� ������� (rapr)
%   hh=(C*H*norm(AA))^2;

[U,RR,V]=svd(AA);s0=diag(RR);[s1,J]=sort(s0);[ss,I]=sort(s0(s0>0));
% ����������� ����������� ����� �� �����������

rho_k=ss;NZ=length(rho_k);% ��������� ����������� �����
lamk=27*rho_k.^4/16;% ����� ������� ������� \beta

%   ����� �� lambda, ���������� lamk
np=8;lamm=linspace(0,lamk(1),np);xx=lamm;NX=np;
for kk=1:NZ-1;dl=linspace(lamk(kk),lamk(kk+1),np);lamm=[lamm dl(2:end)];
xx=[xx dl];NX=[NX length(xx)];% �������� ��� ������� ������� \beta  
end
NL=length(lamm);xx=[xx lamk(end)];
%figure(1);plot(lamm,lamm,'.-',lamk,lamk,'r.');

BE=[];warning off
for ii=1:NL;lam=lamm(ii);
  [beta,ind]=bet_mpm(lam,lamk,rho_k);% ���������� ������� \beta
  BE=[BE beta];% �������� ��� ������� \beta
end 

nrr=min(find(BE>hh));
xxx=xx(NX+1);bbe=BE(NX+1);NNN=min(find(bbe>hh));
Nt=find(xxx(NNN)==lamk);% ����� ������������ �����, ������������� ����

%  ���������� ������� ���������� ����������� ����� (�� ������ ����� ������� ���)
NN=length(s0);NN1=length(ss(Nt:end));

sing=[zeros(NN-NN1,1); ss(Nt:end)];
insing=[zeros(NN-NN1,1); 1./ss(Nt:end)];

B=U*diag(sing(J))*V';IB=U*diag(insing(J))*V';% ������ 1)


rapr=length(ss)-Nt+1;
