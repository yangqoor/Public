function x = simpgdsearch(objfun,gdvalues,addarg,fileout)

% SIMPGRIDSEARCH Multi-dimensional unconstrained nonlinear
%   minimization using grid search + Simplex method.
%
%   X = SIMPGDSEARCH(OBJFUN,GDVALUES) returns a vector X
%   that is a minimizer of the function described in OBJFUN
%   (usually an m file: OBJFUN.M).
%
%   See OBJFUN_DEMO.M for how to write an objective function.
%   It should have one input argument as a vector, of which
%   length is equal to the number of parameters.
%
%   GDVALUES is a cell array of which number of rows is
%   equal to number of parameters. n-th row specifies the
%   grid values for the n-th parameter. All the combination
%   of the grid values are tried (grid search) and then
%   the best parameter set is used as an input guess value
%   for the Nelder-Mead simplex method (FMINSEARCH).
%
%   X = SIMPGDSEARCH(OBJFUN,GDVALUES,ADDARG) passes additional
%   arguments to the objective function. This should be a
%   cell array consisting of a set of arguments.
%
%   SIMPGDSEARCH(OBJFUN,GDVALUES,ADDARG,FILEOUT) writes search
%   result to FILEOUT. Each row in FILEOUT denotes evaluated
%   parameter values and corresponding objective function value. It
%   is in the evaluated order. If there is no additional arguments
%   to be given, then specify [] as ADDARG for this case.
%
%   <Example>
%      param1 = linspace(0,10,10);
%      param2 = linspace(0,8,8);
%      param3 = linspace(2,10,4);
%      param4 = linspace(3,12,12);
%      gdvalues = {param1 param2 param3 param4};
%      objfun = 'objfun_demo';
%      trueval = [2 4 6 8];
%      coef = [1 2 3 4];
%      addarg = {trueval,coef};
%      x = simpgdsearch(objfun,gdvalues,addarg)
%
%   See also FMINSEARCH.
%

%   22 Mar 2005, Yo Fukushima



%% number of dimensions %%
nd = size(gdvalues,2);

%% create parameter step %%
for k = 1:nd
   paramstep(k,:) = gdvalues;
end

%% model: all the combination of the evaluated parameters %%
str = [];
for k = 1:nd
   str = [str 'gdvalues{ ' num2str(k) '},'];
end
str(length(str)) = [];
eval(['model = setprod(' str ');']);

%% grid search %%
for l = 1:size(model,1)
   cost(l) = feval(objfun,model(l,:),addarg);   
end

%% best fit model %%
[minval ind] = min(cost);
x0 = model(ind,:);

%% Simplex method %%
[x,fval] = fminsearch(objfun,x0,[],addarg);

%% save data %%
if nargin == 4
   foo = [model, cost'];
   foo = [foo; x,fval];
   save(fileout,'foo','-ascii');
end

%%%%% EOF %%%%%


% The following lines create the same figure as the snapshot.
%
%      param1 = linspace(0,10,10);
%      param2 = linspace(0,8,8);
%      param3 = linspace(2,10,4);
%      param4 = linspace(3,12,12);
%      gdvalues = {param1 param2 param3 param4};
%      objfun = 'objfun_demo';
%      trueval = [2 4 6 8];
%      coef = [1 2 3 4];
%      addarg = {trueval,coef};
%      x = simpgdsearch(objfun,gdvalues,addarg,'temp.txt');
%      data = load('temp.txt');
%      [minval,ind] = min(data(:,5));
%      figure;
%      subplot(221); plot(data(:,1),data(:,5),'.',data(ind,1),data(ind,5),'r*');
%      xlabel('First Parameter');
%      ylabel('Objective Function');
%      subplot(222); plot(data(:,2),data(:,5),'.',data(ind,2),data(ind,5),'r*');
%      xlabel('Second Parameter');
%      subplot(223); plot(data(:,3),data(:,5),'.',data(ind,3),data(ind,5),'r*');
%      xlabel('Third Parameter');
%      ylabel('Objective Function');
%      subplot(224); plot(data(:,4),data(:,5),'.',data(ind,4),data(ind,5),'r*');
%      xlabel('Fourth Parameter');
%      legend('Evaluated Values','Final Solution');
%    
