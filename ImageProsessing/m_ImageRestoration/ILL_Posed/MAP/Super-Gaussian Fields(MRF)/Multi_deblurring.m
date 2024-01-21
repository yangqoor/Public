function [prob,kListItr]=Multi_deblurring(prob,ret)


k1=prob.k_sz1; k2=prob.k_sz2; 
%choose number of pyramid layers

maxitr=max(floor(log(5/min(k1,k2))/log(ret)),0);

retv=ret.^[0:maxitr];
%set kernel sizes in each pyramid level, but make sure they are all odd 

k1list=ceil(k1*retv);
k1list=k1list+(mod(k1list,2)==0);
k2list=ceil(k2*retv);
k2list=k2list+(mod(k2list,2)==0);

cret=retv(end);
k=resizeKer(prob.k,cret,k1list(end),k2list(end));

for itr=maxitr+1:-1:1
  cret=retv(itr);
  prob.itr=itr;
  
 % initialize filters using Filters0.5.mat that is learned by FoE
 % FoE:Schmidt, U., Gao, Q., Roth, S.: A generative perspective on mrfs in low-level vision.
  load Filters0.5.mat     
  for i=1:8
     prob.filts(:,:,i) = (reshape(FOEs(:,i),3,3));
     JJ = prob.filts(:,:,i);
     prob.J(:,i) = JJ(:);
  end 
  
  sy=downSmpImC(prob.y,cret);
  tprob=prob;
  tprob.y=sy; tprob.k=k; 
  tprob=set_sizes(tprob);
  tprob.filtx=[];
  tprob.x=[]; 

 
  
  if (itr == maxitr+1)
    [~, ~, threshold]= threshold_pxpy_v1(sy,max(size(k)));
  end
  [~, ~, threshold]= threshold_pxpy_v1(sy,max(size(k)));
  
  
  [tprob,kList]=Single_Deblurring(tprob,threshold,itr);

  kListItr{itr}=kList;


  %resize kernel for next iteration.
   tprob.k = adjust_psf_center(tprob.k);
  if (itr>1)
    k=resizeKer((tprob.k),1/ret,k1list(itr-1),k2list(itr-1));
  end

end

prob=tprob;