function [IL,U,V,sig,X,y,w,sss]=L_reg_0(reg,A,u,hx,ht);
%  ��� Nonsatur

[m,n]=size(A);c1=1;
if reg==0;% ������������� � L_2
   L1=diag([0.5 ones(1,n-2) 0.5])*sqrt(ht);sss=' (������������� � L_2)';
   elseif reg==1;% ������������� � W_2^1 -- L-������������� � �������� ��. ���������
     L0=(diag(ones(1,n))-diag(ones(1,n-1),1));L0(1,2)=0;L0(end,end-1)=0;
     L0(1,1)=c1*L0(1,1);L0(end,end)=c1*L0(end,end);
     L00=diag(ones(1,n));L00(end,end)=0.5*L00(end,end);L00(1,1)=0.5*L00(1,1);
      L1=(L00+L0/ht)*sqrt(ht);sss=' (L-������������� � W_2^1)';
   elseif reg==21;% ������������� � W_2^1 � ��������� z'(a)=z'(b)=0
      L0=2*diag(ones(1,n))/ht;L0(1,1)=2/ht;L0(n,n)=L0(1,1);
      L0=L0-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
      LL=L0+diag(ones(1,n))*ht;L1=chol(LL);
      sss=' (������������� � W_2^1)';
   elseif reg==2;% ������������� � W_2^2 -- L-������������� � ��������� z'(a)=z'(b)=0
      L0=2*diag(ones(1,n))/ht;L0(1,1)=2/ht;L0(n,n)=L0(1,1);
      L0=L0-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
      L00=diag(ones(1,n));L00(end,end)=c1*L00(end,end);L00(1,1)=c1*L00(1,1);
      L1=L0+L00*sqrt(ht);sss=' (L-������������� � W_2^2)';
   elseif reg==22;% ������������� � W_2^2 � ��������� z'(a)=z'(b)=0
      L0=2*diag(ones(1,n))/ht;L0(1,1)=2/ht;L0(n,n)=L0(1,1);
      L0=L0-diag(ones(1,n-1),1)/ht-diag(ones(1,n-1),-1)/ht;
      LL=L0'*L0+diag(ones(1,n))*ht;L1=chol(LL);sss=' (������������� � W_2^2)';
   else disp('  ����������� �������������!');disp(' ');return;end
   

IL=inv(L1);B=A*IL;y=B'*u;[U,RA,V]=svd(B);w=V'*y;sig=diag(RA).^2;X=IL*V;
