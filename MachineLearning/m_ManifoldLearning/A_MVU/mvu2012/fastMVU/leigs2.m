function [Y,eigenvals] = leig2(DD, d,varargin)  
% function [Y,eigenvals] = leig2(DD, d,varargin)  
%
% Input:
%
% DD : sparse distance matrix (0 means not connected)
% d  : number of output diimensions desired
%
% Output:
%
% Y         : output vectors (top row is smoothest dimension)
% eigenvals : output eigenvalues 
%
%
% See also isomap, lle, spe, mds, pca
%
%
% copyright Kilian Q. Weinberger 2006


pars.normalized=0;
pars=extractpars(varargin,pars);

W = (DD~=0);
clear('DD');  
disp('Computing Laplacian eigenvectors.');
D = sum(W,2);   
L = spdiags(D,0,speye(size(W,1)))-W;


%%%%%%%%%%%%%%%%%%%%%
% normalized Laplacian
if(pars.normalized)
 fprintf('Using normalized Laplacian\n');
 for i=1:size (L)
  j=find(L(:,i));
  L(j,i)=L(j,i)./(sqrt(D(j))*sqrt(D(i)));
  L(i,j)=L(j,i)';
 end
end;
%%%%%%%%%%%%%%%%%%%%%



opts.tol = 1e-29;
opts.issym=1; 
opts.disp = 0;



[E,eigenvals] = eigs(L,d+1,'sm',opts);  
[temp,i]=min(var(E)); 
E(:,i)=[];
eigenvals=diag(eigenvals);eigenvals(i)=[];
[temp,i]=sort(eigenvals);
Y=E(:,i)';





