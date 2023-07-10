function [ymvu,Details]=fastmvu(DD,outdim,varargin);
% function [ymvu,Details]=fastmvu(DD,outdim,varargin);
%
% Computes a low dimensional embedding of data points that are only specified by sparse local distances.
%
% INPUT:
%
% DD : Sparse SQUARED-distance matrix 

%
% copyright Kilian Q. Weinberger, 2006

pars.maxiter=10000;
pars.eta=1e-04;
pars.leigsdim=10;
pars.random=0;
pars=extractpars(varargin,pars);

scale=sqrt(max(max(DD)));
scale=1;
DD=DD./scale;


if(~connectedG(DD))
 error('Sorry, graph not connected. Please use more neighbors or bigger epsilon ball. Thanks. ');
end;

%[AA,b,K,DD]=getAbK(x,pars.mvueps^2,pars.noise,'maxk',pars.maxk);

if(~pars.random) 
    tic;
  [xlap,v]=leigs2(DD,pars.leigsdim);
  Details.time.lap=toc;

 degree=full(sum(DD>0));
fprintf('Min degree: %i Max degree:%i Mean degree:%3.2f Median degree: %i\n',min(degree),max(degree),mean(degree),median(degree));


 max(sum((DD)>0))
 neigh=zeros(max(sum(DD>0)),length(DD));
 for i=1:length(DD)
  jj=find(DD(:,i));  
  neigh(1:length(jj),i)=jj;
 end; 
 
 tic;
 [p,ymvuLap,ne,cost,c]=sdecca2(xlap,triu(DD),pars.eta,0);
Details.time.fei=toc;
 

else
 ymvuLap=center(rand(pars.leigsdim,size(DD,2)));  
 xlap=[];
end;


fprintf('%iD Conjugate gradient descent ... \n',pars.leigsdim);
tic;
[ymvu,Details.hillobj]=hillclimber2c(DD,ymvuLap,'maxiter',pars.maxiter,'eta',pars.eta,'printevery',100);


[u,v]=pca(ymvu);
ymvu=u'*ymvu;
ymvu=ymvu(1:outdim,:);
fprintf('\n2D Conjugate gradient descent ... \n');
[ymvu,Details.hillobj2]=hillclimber2c(DD,ymvu,'maxiter',pars.maxiter,'eta',0);

Details.time.hill=toc;
Details.globalpars=pars;
Details.xlap=xlap;
Details.ymvuLap=ymvuLap;

ymvu=full(ymvu.*scale);

