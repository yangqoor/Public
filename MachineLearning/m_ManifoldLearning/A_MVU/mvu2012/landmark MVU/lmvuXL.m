function [Y,details]=lmvuXL(X,B,K,varargin)
% [Y,details]=lmvuXL(X,B,K,pars)
%
% Similar to lmvu but for large data sets 
%
% INPUT:
% X = Input vectors (columns)
% B = Number of Landmarks (Default = 30) (fewer is faster) 
% k = Nearest neighbors for mvu constraints (Default = 3)
%
% pars.solver = (0 Default) 0=CSDP, 1=SeDuMi, 2=SDPT
% pars.LL = (12 Default) nearest neighbors for reconstruction
% pars.maxiter = (100 Default) maximum number of iterations
% pars.margin = (0.1 Default) percent error allowed for constraints
% pars.warmup = (Highly Optional) the fraction of constraints to be
%               considered initially
%
% OUTPUT:
%
% Y = Output column vectors 
% details=
%                    k: original k
%                    D: eigenvalues of kernel (reveal dimensionality)
%                 info: output of sdp solver
%                 pars: original pars field
%                 dual: dual solution
%                QFull: matrix Q 
%            landmarks: indices random landmarks
%                    B: number of landmarks
%                    L: matrix L (kernel matrix of landmarks)
%                   gi: random order of landmarks (only internally)
%                 time: time needed for computation
%           constraint: constraints used for sdp
%     TotalConstraints: constraints monitored
%
% To obtain d dimensional output set 
% Youtput=Y(1:d,:);
%
% Version 1.3
% copyright by Kilian Q. Weinberger (2005)
% http://www.seas.upenn.edu/~kilianw/
%
%
% HINT: Since version 1.3, parameters can also be passed on as strings 
% (after the number of neighbors)
% e.g. 
% [Y,Det]=lmvuXL(X,20,3,'LL',12);
% is equivalent to 
% pars.LL=12
% [Y,Det]=lmvuXL(X,20,3,pars);
%

 
if(nargin==0)
  help lmvuXL;
  return;
end;

N=size(X,2);

fprintf('%i input vectors of dimensions %i\n',N,size(X,1));

if(nargin<2)
 B=30;
end;
if(nargin<3)
 K=3;
end;


% extract variables
if(length(varargin)>=1)
 if(~isstr(varargin{1}))
    pars=varargin{1};
    for j=1:length(varargin)-1
        varargin{j}=varargin{j+1};
    end;
 end;

 for i=1:nargin-3
 if(isstr(varargin{i}))
    if(i+1>nargin-3 | isstr(varargin{i+1})) val=1;else val=varargin{i+1};end;
    eval(['pars.' varargin{i} '=' sprintf('%i',val) ';']);
 end;
 end;
end;


if(~exist('pars') | ~isfield(pars,'solver')) pars.solver=0;end; 
if(~isfield(pars,'ep')) pars.ep=eps;end;
if(~isfield(pars,'fastmode')) pars.fastmode=1;end;
if(~isfield(pars,'warmup')) pars.warmup=K*B/N;end;
if(~isfield(pars,'verify')) pars.verify=1;end;
if(~isfield(pars,'angles')) pars.angles=1;end;
if(~isfield(pars,'LL')) pars.LL=10;end;
if(~isfield(pars,'maxiter')) pars.maxiter=100;end;
if(~isfield(pars,'noise')) pars.noise=0;end;
if(~isfield(pars,'ignore')) pars.ignore=0.1;end;

if(~isfield(pars,'penalty')) pars.penalty=1;end;
if(~isfield(pars,'factor')) pars.factor=0.9999;end;
if(~isfield(pars,'save')) pars.save=0;end;

if(~isfield(pars,'kmeans')) pars.kmeans=0;end;




gi=randperm(N);


if(pars.kmeans)

 fprintf('KMeans ...');
 [u,ass]=kmeans(X,B);
 dd=distance(X,u);
 [temp, gi]=min(dd);
 ll=ones(1,N);
 ll(gi)=0;
 gi2=find(ll);
 gi=[gi gi2(randperm(length(gi2)))];
 fprintf('done\n');
end;



[temp,oi]=sort(gi);
X=X(:,gi);

fprintf('SDLLE Version 0.9999 XXL \n');
pars





KK=max(pars.LL,K);
if(~isfield(pars,'neighbors') | size(pars.neighbors,1)<KK)
 neighbors=getnearestmem(X,KK);
else
 neighbors=pars.neighbors(1:KK,:);
 pars.neighbors=0;
end;


if(pars.save==1) 
    filename=sprintf('temp%i',pars.save)
    save(filename,'neighbors');
end;

[Pia,mui]=getPia(B,pars.LL,K,X,pars,neighbors);
fprintf('Generating SDP problem ...');


neighbors=neighbors(1:K,:);
clear('temp');
clear('index');
clear('sorted');

tic;

nck=nchoosek(1:(K+1),2);
AA=zeros(N*K,2);
pos3 = 1;
for i=1:N
   ne = neighbors(:,i);
   nne=[ne;i];
   pairs=nne(nck); 
   js=pairs(:,1);
   ks=pairs(:,2);
   
    AA(pos3:pos3+length(js)-1,:)=sort([js ks]')';
    pos3 = pos3 + length(js);
    if(i==B)
      AA=unique(AA,'rows');
      ForceC=size(AA,1);
    end;
    if(pos3>size(AA,1) & i<N)
      AA=unique(AA,'rows');
      pos3=size(AA,1)+1;

      AA=[AA;zeros(round(N/(N-i)*pos3),2)];
      fprintf('.');
    end;
end;

AA=unique(AA,'rows');
AA=AA(2:end,:);%erase the [0 0] entry
clear('neighbors','ne','v2','v3','js','ks');
TotalConstraints=size(AA,1)+1;



 for i=1:size(AA,1)
%     bb(i)=DD(AA(i,1),AA(i,2));
    bb(i)=sum((X(:,AA(i,1))-X(:,AA(i,2))).^2);
 end;
 

%% Reduce the number of forced vectors
ii=[1:ForceC]';
jj=zeros(1,size(AA,1));
jj(ii)=1; jj=find(jj==0);

jj1=jj(find(jj<=ForceC));
jj2=jj(find(jj>ForceC));
jj2=jj2(randperm(length(jj2)));
jj1=jj1(randperm(length(jj1)));

corder=[ii;jj1';jj2'];
AA=[AA(corder,:)];
bb=bb(corder);
ForceC=length(ii);
clear('temp','jj1','jj2','jj','ii');


Const = max(round(pars.warmup*size(AA,1)),ForceC);


[A,b,AA,bb] = getConstraints(AA,Pia,bb,B,Const,pars);

Qt=sum(Pia,1)'*sum(Pia,1); % Add sum-to-zero constraint
A=[Qt(:)';A];
b=[0;b];


Kneigh=K;


clear('K');
solved=0;
fprintf('done (%s)\n\n',timestamp);

while(solved==0)
 fprintf('Size of A: %ix%i \n\n\n',size(A));

 c=0-vec(Pia'*Pia);


flags.s=B;
flags.l=size(A,1)-1;  
A=[[zeros(1,flags.l); speye(flags.l)] A];


 if(pars.penalty)
  c=[ones(ForceC,1).*max(max(c));zeros(flags.l-ForceC,1);c];
 else
  c=[zeros(ForceC,1);zeros(flags.l-ForceC,1);c];  
 end;

 
 fprintf('Omit %i constraints\n',TotalConstraints-size(A,1));

 switch(pars.solver)
  case{0},
   options.maxiter=pars.maxiter;
%   options.printlevel=0;
   [x d z info]=csdp(A,b,c,flags,options);
   K=mat(x(flags.l+1:flags.l+flags.s^2));
  case{1},        
   [k d info]=sedumi(A,b,c,flags);
   K=mat(k(end-flags.s^2+1:end)); 
  case{2},
   fprintf('converting into SQLP...');
   Ap=A;bp=b;cp=c;
   [blk,A,c,b]=convert_sedumi(A',b,c,flags);
   fprintf('DONE\n');
   if(exist('K'))  
     fprintf('Initializing ...');
     % Initialize with input points
     [X0,y0,Z0]=infeaspt(blk,A',c,b); 
     X0{length(X0)}=K+speye(B).*0.001;
     %        X0{length(X0)}=K;
     fprintf('DONE\n');
     [obj,Kt,d,z,info]=sqlp(blk,A,c,b,{},X0,y0,Z0);
   else
     [obj,Kt,d,z,info]=sqlp(blk,A,c,b);
   end;
   info=info(1);
   K=Kt{length(Kt)};
   info=0;
   clear('A','b','c');
   A=Ap;b=bp;c=cp;
 end;
 fprintf('(%s)\n',timestamp);
  
 solved=(isempty(AA));
 A=A(:,flags.l+1:end);
 xx=K(:);
 if(size(AA,1))
   Aold = size(A,1);
   total=0;
   while size(A,1)-Aold<Const & ~isempty(AA)
     [newA,newb,AA,bb] = getConstraints(AA,Pia,bb,B,Const,pars);
     jj=find(newA*xx-newb>pars.ignore*abs(newb));
     if(info==2) 
         jj=1:size(newA,1);
     end;
     if(length(jj)>0)
      fprintf('Violated constraints:%i\n',length(jj));
     end;
      total=total+length(jj);
     A(size(A,1)+1:size(A,1)+length(jj),:) = newA(jj,:);
     b(length(b)+1:length(b)+length(jj)) = newb(jj);
   end;

   fprintf('Total violated constraints:%i (%s)\n',total,timestamp);
   if(total==0) solved=1;end;
 else
   solved=1;  
 end;

 if(solved==1 & pars.maxiter<100) pars.maxiter=100; end;
end;

%keyboard;
[V D]=eig(K);
V=V*sqrt(D);
Y=(V(:,end:-1:1))';
Y=Y*Pia';


details.k=Kneigh;
details.D=diag(D);
details.info=info;
details.pars=pars;
details.dual=d;
details.Pia=Pia;
details.mui=mui;
details.B=B;
details.K=K;
details.gi=gi;
details.time=toc;
details.constraints=size(A,1);
details.TotalConstraints=TotalConstraints;
Y=Y(:,oi);













function [Q,mui]=getPia(B,LL,K,X,pars,neighbors);

N=size(X,2);
mui=1:B;



fprintf('Generating Weight-Matrix ...');
tol=1e-4; 
Pia = sparse([],[],[],B,N);
for i=1:N
  z = X(:,neighbors(:,i))-repmat(X(:,i),1,LL);
  C = z'*z;
  C = C + tol*trace(C)*eye(LL)/LL; % REGULARIZATION
  invC = inv(C);
  Pia(neighbors(:,i),i) = sum(invC)'/sum(sum(invC));
end;


M=speye(N)+sparse([],[],[],N,N,N*LL^2);
for i=1:N 
  j = neighbors(:,i);
  w = Pia(j,i);
  M(i,j) = M(i,j) - w';
  M(j,i) = M(j,i) - w;
  M(j,j) = M(j,j) + w*w';
end;

fprintf('done (%s)\n',timestamp);
clear('neighbors','Pia','invC','w','j','C','w','X');

fprintf('Inverting matrix ... ');
Q=-M(B+1:end,B+1:end)\M(B+1:end,1:B);
fprintf('done (%s)\n',timestamp);
Q=[eye(B);Q]; 
















function [A,b,AAomit,bbomit] = getConstraints(AA,Pia,bb,B,Const,pars)
pos2=0;

perm = randperm(size(AA,1));
perm=1:size(AA,1);
if size(AA,1)>Const
  AAomit = AA(perm(Const+1:end),:);
  bbomit = bb(perm(Const+1:end));
  AA = AA(perm(1:Const),:);
  bb = bb(perm(1:Const));
else
  AAomit = [];
  bbomit = [];
end;


persistent reqmem;
if(isempty(reqmem))
 A2=zeros(size(AA,1)*B,3);
else
 A2=zeros(reqmem,3);  
end;
 %b=zeros(size(AA,1),1);
pos=0;
for j = 1:size(AA,1)

    ii=AA(j,1);
    jj=AA(j,2);
    Q=Pia(ii,:)'*Pia(ii,:)-2.*Pia(jj,:)'*Pia(ii,:)+Pia(jj,:)'*Pia(jj,:);
    Q=(Q+Q')./2;
 
    it=find(abs(Q)>pars.ep^2);
    
    if(length(it)>0)
         pos=pos+1;
     if(pos2+length(it)>size(A2,1))
       % Allocate more memory
       A2=[A2;zeros(ceil((size(AA,1)-j)/j*size(A2,1)),3)];
     end;
     A2(1+pos2:pos2+length(it),1)=ones(length(it),1).*pos;
     A2(1+pos2:pos2+length(it),2)=it;
     A2(1+pos2:pos2+length(it),3)=full(Q(it));
 
     pos2=pos2+length(it);
   
    end;
end;

reqmem=pos2;
A2=A2(1:pos2,:);
A=sparse(A2(:,1),A2(:,2),A2(:,3),size(AA,1),B^2);
clear('A2');

b=bb';




  

function s=timestamp;
s='';
% t=round(toc);
% if(t<60)
% s=sprintf('%is',t);
%else
% t=floor(t/60);
%
%  if(t<60)
%    s=sprintf('%im',t);
%  else
%   h=floor(t/60);
%   m=t-h*60;
%   s=sprintf('%ih %im',h,m);
%  end;
%end;




function v=vec(M);

v=M(:);


function M=mat(C);

r=round(sqrt(size(C,1)));
M=reshape(C,r,r);
