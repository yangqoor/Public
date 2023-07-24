function [A,b,c]=getCorAb(x,y,cov,k_sz1,k_sz2)

A1=getAutoCor(x,k_sz1,k_sz2);
b=getCory(x,y,k_sz1,k_sz2);
c=sum(abs(y(:)).^2);
[M1,M2]=size(x);
[N1,N2]=size(y);
    
k_sz=k_sz2*k_sz1;
M=M1*M2;
A=zeros(k_sz,k_sz);
for d1=-(k_sz1-1):k_sz1-1
   for d2=0:k_sz2-1
      d=d2*M1+d1;
      if (d<0)
          continue
      end
      
      cs=(diag(cov,d));
      cs=[cs;zeros(M-length(cs),1)];
      cs=reshape(cs,M1,M2);
      tcs=cumsum(cumsum(cs),2);
      cs=zeros(M1+1,M2+1); 
      cs(2:end,2:end)=tcs; 
      for i1=1:k_sz1
	 for i2=1:k_sz2
	    ki1=i1+(i2-1)*k_sz1;
            ki2=i1+d1+(i2+d2-1)*k_sz1;
            if (((i1+d1)>k_sz1)| ((i2+d2)>k_sz2))
              continue
            end    
            e1=M1-k_sz1+i1+1; e2=M2-k_sz2+i2+1;
            ts=cs(e1,e2)-cs(e1,i2)-cs(i1,e2)+cs(i1,i2);
            A(ki1,ki2)=ts;
            A(ki2,ki1)=ts;
         end
      end

   end
end

A=full(A)+full(A1);  
  
  
  
  
  
  
  
  
  