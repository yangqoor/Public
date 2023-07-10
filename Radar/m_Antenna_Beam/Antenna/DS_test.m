% to prove that the shifts of DS and their respective complementary sets are cyslic difference sets 
clear;
V=63;
K=32;
L=16;
D=[0 5 6 10 12 15 16 17 18 20 24 25 26 29 32 34 35 37 38 39 41 42 45 46 48 50 52 53 54 55 56 57];
Dempty=zeros(1,V);
Dfull=0:V-1;
Dcomp=zeros(1,V-K);
Dempty(D+1)=D;
Dfull=Dfull-Dempty;
n=0;
for m=1:V
    if Dfull(m)~=0
       n=n+1;
       Dcomp(n)=Dfull(m);
   end
end
Dcomp=sort(Dcomp);
Ds=zeros(V,K);
Dscomp=zeros(V,V-K);
Table1=zeros(K,K);
Table2=zeros(V-K,V-K);
for s=0:V-1
    Ds(s+1,:)=mod(D+s,V);
    Ds(s+1,:)=sort(Ds(s+1,:));
    Dscomp(s+1,:)=mod(Dcomp+s,V);
    Dscomp(s+1,:)=sort(Dscomp(s+1,:));
    for m=1:K
        for n=1:K
        Table1(m,n)=mod(Ds(s+1,m)-Ds(s+1,n),V);
        end
    end
    for m=1:V-K
        for n=1:V-K
        Table2(m,n)=mod(Dscomp(s+1,m)-Dscomp(s+1,n),V);
        end
    end
    num1=zeros(1,V-1);
    for l=1:V-1
        num1(l)=length(find(Table1==l));
        if num1(l)~=L
           disp('the shift s of DS is not a cyclic difference set');
           break;
        end
   end
   num2=zeros(1,V-1);
   for l=1:V-1
        num2(l)=length(find(Table2==l));
        if num2(l)~=V-2*K+L
           disp('the complementary of DS by shift s  is not a cyclic difference set');
           break;
        end
   end
end