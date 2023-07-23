function [U,V,sig,X,y,w,sss]=L_reg2(reg,A,u,hx,ht);
%  ��� Smooth_infl

[m,n]=size(A);c1=1;
if reg==0;% ������������� � L_2
   L1=diag([0.5 ones(1,n-2) 0.5])*(ht);sss=' (������������� � L_2)';%sqrt
   elseif reg==1;% ������������� � W_2^1 -- � �������� ��. ���������
      L0=2*diag(ones(1,n))/ht;%L0(1,1)=1/ht;L0(n,n)=L0(1,1);
      L0=L0-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
      LL=L0+diag(ones(1,n))*ht;L1=chol(LL);% 
      sss=' (������������� � W_2^1; z(a)=z(b)=0)';
   elseif reg==21;% ������������� � W_2^1 � ��������� z'(a)=z'(b)=0
      L0=2*diag(ones(1,n))/ht;L0(1,1)=1/ht;L0(n,n)=L0(1,1);
      L0=L0-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
      LL=L0+diag(ones(1,n))*ht;L1=chol(LL);
      sss=' (������������� � W_2^1)';
   elseif reg==22;% ������������� � W_2^2 � ��������� z'(a)=z'(b)=0
      L0=(2+6/ht^2)*diag(ones(1,n))/ht+diag(ones(1,n))*ht;%L0(1,1)=1/ht;L0(n,n)=L0(1,1);
      LL=L0-(1+4/ht^2)*diag(ones(1,n-1),1)/ht-(1+4/ht^2)*diag(ones(1,n-1),-1)/ht+...
        diag(ones(1,n-2),2)/ht^3+diag(ones(1,n-2),-2)/ht^3;
      %LL=L0'*L0+diag(ones(1,n))*ht;
      L1=chol(LL);sss=' (������������� � W_2^2)';
   else disp('  ����������� �������������!');disp(' ');return;end
   

IL=inv(L1);B=A*IL;y=B'*u;[U,RA,V]=svd(B);w=V'*y;sig=diag(RA).^2;X=IL*V;
