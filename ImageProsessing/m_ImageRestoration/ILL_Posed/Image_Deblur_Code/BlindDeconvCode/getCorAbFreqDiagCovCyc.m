function [A,b,c]=getCorAbFreqDiagCovCyc(x,y,xfreqcov,k_sz1,k_sz2)



    
A=getAutoCorCyc(x,k_sz1,k_sz2);
b=getCoryCyc(x,y,k_sz1,k_sz2);
Ac=getAutoCorFreqDiagCov(xfreqcov,k_sz1,k_sz2);
 
A=A+Ac;

c=sum(sum(abs(y).^2));

return
