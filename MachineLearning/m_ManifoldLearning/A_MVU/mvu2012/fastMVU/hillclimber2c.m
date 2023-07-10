function [x,obj]=hillclimber2c(DD,x,varargin);
% function [x,obj]=hillclimber2(DD,x,varargin);
%
%
% copyright by Kilian Q. weinberger, 2006

n=length(DD);
pars.maxiter=10000;
pars.stepsize=1e-05;
pars.ETA=1e0-5;
pars.truex=[];
pars.verbose=1;
pars.acc=1.01;
pars.printevery=100;
pars.othresh=1e-10;
pars.eta=0;
pars=extractpars(varargin,pars);

scale=1;
DD=DD./scale;
x=x./sqrt(scale);

ii=find(DD);
dd=full(DD(ii));
[i2,i1]=ind2sub(size(DD),ii);
dims=size(x);

%save('temp');
%checkgrad('hill_obj',x(:),1e-07,dims,[i1 i2],dd,pars);
[x,obj,i]=minimize(x(:),'hill_obj',-pars.maxiter,dims,[i1 i2],dd,pars);
i
x=reshape(x,dims);
x=x.*sqrt(scale);
