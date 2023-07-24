function [A,b,c]=getCorAbFreqDiagCov(x,y,xfreqcov,k_sz1,k_sz2,bdr)



%remove boundaries to reduce some of the mess from the cyclic deconvolution
if ~exist('bdr','var')
   bdr=ceil(max(k_sz1,k_sz2)*0.6); 
end


hk_sz1=floor(k_sz1/2-0.5);
hk_sz2=floor(k_sz2/2-0.5);


if (size(y,1)==size(x,1))
  y=y(hk_sz1+1:end-hk_sz1,hk_sz2+1:end-hk_sz2);
end
    
A=getAutoCor(x(bdr+1:end-bdr,bdr+1:end-bdr),k_sz1,k_sz2);
b=getCory(x(bdr+1:end-bdr,bdr+1:end-bdr),y(bdr+1:end-bdr,bdr+1:end-bdr)...
                          ,k_sz1,k_sz2);
Ac=getAutoCorFreqDiagCov(xfreqcov,k_sz1,k_sz2);
 
r=(size(x,1)-2*bdr-k_sz1+1)*(size(x,2)-2*bdr-k_sz2+1)/prod(size(xfreqcov));
A=A+r*Ac;

c=sum(sum(abs(y(bdr+1:end-bdr,bdr+1:end-bdr)).^2));

return
