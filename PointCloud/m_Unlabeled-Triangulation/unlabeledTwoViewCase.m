function Mopt = unlabeledTwoViewCase(M,M0)
   alpha=eig(M{2},M{2}-M{1});
   Mres{1}=alpha(1)*M1+(1-alpha(1))*M2; Mres1=Mres1/Mres1(4,4);
   Mres{2}=alpha(2)*M1+(1-alpha(2))*M2; Mres2=Mres2/Mres2(4,4);
   Mres{3}=alpha(3)*M1+(1-alpha(3))*M2;  Mres3=Mres3/Mres3(4,4);
   Mres{4}=alpha(4)*M1+(1-alpha(4))*M2;  Mres4=Mres4/Mres4(4,4);
   [~,ind]=max([norm(M0-Mres1,'fro') norm(M0-Mres2,'fro') norm(M0-Mres3,'fro') norm(M0-Mres4,'fro')]);
   [u,d,v]=Mres{ind};
   d(3:4,3:4)=0;
   Mopt=u*d*v';
   end

