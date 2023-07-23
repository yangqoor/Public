function Du=odu_ku(t,U,flag,n,A,B,uu,ku,F,tt)
% dU/dt=k(U)[U(x-h,t)-2U(x,t)+U(x+h,t)]/h^2+k'(U){[U(x+h,t)-U(x,t)]/h}^2
KU=interp1(uu,ku,U);DKU=[0; diff(KU)];%  k(U)
nn=find(isnan(KU));
f0=0;%interp1(tt,F,t); 
if ~isempty(nn);disp(' ');disp('** U вне пределов по u **');disp(' ');
   figure(66);plot(U);return;end
Du=KU.*(A*U)+DKU.*(B*U).^2+f0*ones(size(U));% 