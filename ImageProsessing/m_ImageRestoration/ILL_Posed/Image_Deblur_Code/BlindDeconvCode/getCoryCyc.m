function b=getCoryCyc(x,y,k_sz1,k_sz2)
[M1,M2]=size(x);

hk_sz1=floor(k_sz1/2-0.5);
hk_sz2=floor(k_sz2/2-0.5);

    
k_sz=k_sz1*k_sz2;
b=zeros(k_sz,1);


ind=0;
for d2=-hk_sz2:k_sz2-1-hk_sz2
  for d1=-hk_sz1:k_sz1-1-hk_sz1
    ii1=mod([1:M1]+d1-1,M1)+1;
    ii2=mod([1:M2]+d2-1,M2)+1;
    ts=sum(sum(y.*x(ii1,ii2)));  
    ind=ind+1;
    b(ind)=ts;
  end
end

