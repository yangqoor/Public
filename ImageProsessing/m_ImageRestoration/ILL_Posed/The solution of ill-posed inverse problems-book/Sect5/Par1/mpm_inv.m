function [B,B1,IB,IB1,rapr]=mpm_inv(AA,hh)
%   Вычисление матрицы МПМ и обратной матрицы МПМ двумя способами (B,B1,IB,IB1). 
%   Оценка ранга матрицы (rapr)
%   hh=(C*H*norm(AA))^2;

[U,RR,V]=svd(AA);s0=diag(RR);[s1,J]=sort(s0);[ss,I]=sort(s0(s0>0));
% Упорядочили сингулярные числа по возрастанию

rho_k=ss;NZ=length(rho_k);% Ненулевые сингулярные числа
lamk=27*rho_k.^4/16;% Точки разрыва функции \beta

%   Сетка по lambda, включающая lamk
np=8;lamm=linspace(0,lamk(1),np);xx=lamm;NX=np;
for kk=1:NZ-1;dl=linspace(lamk(kk),lamk(kk+1),np);lamm=[lamm dl(2:end)];
xx=[xx dl];NX=[NX length(xx)];% Абсциссы для графика функции \beta  
end
NL=length(lamm);xx=[xx lamk(end)];
%figure(1);plot(lamm,lamm,'.-',lamk,lamk,'r.');

BE=[];warning off
for ii=1:NL;lam=lamm(ii);
  [beta,ind]=bet_mpm(lam,lamk,rho_k);% Вычисление функции \beta
  BE=[BE beta];% Ординаты для функции \beta
end 

nrr=min(find(BE>hh));
xxx=xx(NX+1);bbe=BE(NX+1);NNN=min(find(bbe>hh));
Nt=find(xxx(NNN)==lamk);% Номер сингулярного числа, определяющего ранг

%  1) Вычисление матрицы отсечением сингулярных чисел (по оценке ранга методом МПМ)
NN=length(s0);NN1=length(ss(Nt:end));

sing=[zeros(NN-NN1,1); ss(Nt:end)];
insing=[zeros(NN-NN1,1); 1./ss(Nt:end)];

%  2) Вычисление матрицы МПМ по алгоритму
%LAM=xx(nrr);nr1=min(find(lamk>=LAM));
LAM1=xx(nrr);LAM2=xx(nrr-1);LAM=interp1([BE(nrr-1) BE(nrr)],[LAM2 LAM1],hh);
[new_rho,innew_rho]=rho_mpm(LAM,lamk,rho_k);


B=U*diag(sing(J))*V';IB=U*diag(insing(J))*V';% Способ 1)
B1=U*diag(new_rho(J))*V';IB1=U*diag(innew_rho(J))*V';% Способ 2)


rapr=length(ss)-Nt+1;
