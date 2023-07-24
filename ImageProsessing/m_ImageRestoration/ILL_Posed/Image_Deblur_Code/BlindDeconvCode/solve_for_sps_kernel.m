function [k,k_lk]=solve_for_sps_kernel(A,b,k_sz1,k_sz2,scla);

exp_a=0.5;
thr_0=0.0001; 
if ~exist('scla','var')
  scla=0.005;
end
A0=(A+A')/2;
k=quadprog(A0,-b,[],[],[],[],zeros(k_sz1*k_sz2,1));


for itr=1:2
  w=max(abs(k),thr_0).^(exp_a-2);
  k=quadprog(A0+scla*diag(w),-b,[],[],[],[],zeros(k_sz1*k_sz2,1));
end

k=reshape(k,k_sz1,k_sz2);
