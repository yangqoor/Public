function [A]=getAutoCorCyc(x,k_sz1,k_sz2)


[M1,M2]=size(x);
    
k_sz=k_sz1*k_sz2;
A=zeros(k_sz,k_sz);


i_ind=0;
for i2=0:k_sz2-1
  for i1=0:k_sz1-1
     i_ind=i_ind+1;
     j_ind=0;
     for j2=0:k_sz2-1
       for j1=0:k_sz1-1
          j_ind=j_ind+1; 
          
          if (min(i1,j1)==0)&(min(i2,j2)==0)
             ii1=mod([1:M1]+i1-1,M1)+1;
             ii2=mod([1:M2]+i2-1,M2)+1;
             jj1=mod([1:M1]+j1-1,M1)+1;
             jj2=mod([1:M2]+j2-1,M2)+1;
    
             ts=sum(sum(x(jj1,jj2).*x(ii1,ii2)));  
             A(i_ind,j_ind)=ts;
       
          else
            i1m=i1-min(i1,j1); j1m=j1-min(i1,j1);
            i2m=i2-min(i2,j2); j2m=j2-min(i2,j2);
            i_ind_m=i1m+1+i2m*k_sz1;
            j_ind_m=j1m+1+j2m*k_sz1;
            A(i_ind,j_ind)=A(i_ind_m,j_ind_m);
          end
       end
     end
     
  end
end

