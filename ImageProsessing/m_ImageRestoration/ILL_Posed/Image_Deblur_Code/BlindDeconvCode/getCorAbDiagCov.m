function [A,b,c]=getCorAbDiagCov(x,y,xcov,k_sz1,k_sz2)

  A=getAutoCor(x,k_sz1,k_sz2);
  b=getCory(x,y,k_sz1,k_sz2);

  [M1,M2]=size(x);
  [N1,N2]=size(y);
  M=M1*M2;
  cs=cumsum(cumsum(xcov,1),2);
  
  ind=0;
  for i2=1:k_sz2
    for i1=1:k_sz1
      ind=ind+1;
      ts=cs(i1+N1-1,i2+N2-1);
      if (i1>1)
        ts=ts-cs(i1-1,i2+N2-1);
      end
      if (i2>1)
        ts=ts-cs(i1+N1-1,i2-1);
      end
      if ((i1>1)&(i2>1))
          ts=ts+cs(i1-1,i2-1);
      end
      A(ind,ind)=A(ind,ind)+ts;
      
    end
  end
  
  c=sum(abs(y(:)).^2);
  
return
  
  

