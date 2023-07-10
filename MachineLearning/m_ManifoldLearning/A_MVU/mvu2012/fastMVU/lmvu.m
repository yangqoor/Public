function [Y,details]=lmvu(DD,B,k,varargin)
%
% [Y,details]=lmvu(DD,B,k,pars)
%
% INPUT:
%
% DD = Squared Distance Matrix of Input Vectors
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
% [Y,Det]=lmvu(DD,20,3,'LL',12);
% is equivalent to 
% pars.LL=12
% [Y,Det]=lmvu(DD,20,3,pars);
%
 
if(nargin==0)
  help lmvu;
  return;
end;

if(nargin<2)
   B=30;
end;
if(nargin<3)
    k=3;
end;

N=size(DD,1);
tic;



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

% Which solver do you want to use?
if(~exist('pars') | ~isfield(pars,'solver')) pars.solver=0;end; 
% What is insigificantly small?
if(~isfield(pars,'ep')) pars.ep=eps;end;
% What fraction of constraints should be considered initially?
if(~isfield(pars,'warmup')) pars.warmup=k*B/N;end;
% Neighborhood size for the reconstruction?
if(~isfield(pars,'LL')) pars.LL=10;end;
% Maximum number of iterations?
if(~isfield(pars,'maxiter')) pars.maxiter=100;end;
% What is the percentage of error that we allow?
if(~isfield(pars,'margin')) pars.margin=0.1;end;
% Should the slack be penalized?
if(~isfield(pars,'penalty')) pars.penalty=0;end;



% At the very beginning, all input vectors are put in random order.
% The first B vectors according to this new order are the landmarks.
% pars.gi defines the random order, and hence the first B vectors of
% pars.gi are the landmarks. 
% default: pars.gi=randperm(size(X,2));
% (pars.gi is an undocumented feature)
if(~isfield(pars,'gi'))
 gi=randperm(N);
else
 gi=pars.gi; 
end;


 [temp,oi]=sort(gi);
DD=DD(gi,gi);
if(isfield(pars,'G'))
    pars.G=pars.G(gi,gi);
end;

if(size(DD,1)~=size(DD,2)) 
    fprintf('First input matrix must be distance square matrix\n');
    Y=[];
    details='B>N!!! Not possible';
    return;
end;

fprintf('lmvu Version 1.0 \n');
pars



% Compute matrix Q
[QFull,mui]=getQ(B,pars.LL,k,DD,pars);
fprintf('Generating SDP problem ...');

oo=randperm(N);
iforce=1:B;
rest=B+1:N;

order=[iforce rest]';
DD=DD(order,order);
QFull=QFull(order,:);
[temp, original]=sort(order);

% Find neighbors
try
 [sorted,index] = sort(DD);
 neighbors = index(2:(1+k),:);
catch
  neighbors=zeros(k,N);
  for i=1:N  
    [sorted,index]=sort(DD(:,i));
    neighbors(:,i) = index(2:(1+k));
  end;
end;



clear('temp');
clear('index');
clear('sorted');
clear('iforce');

% Compute Constraints
nck=nchoosek(1:(k+1),2);
AA=zeros(N*k,2);
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
        ForceC=size(AA,1)-1;
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
clear('neighbors','ne','js','ks');
TotalConstraints=size(AA,1)+1;

try
    bb=DD(sub2ind([N N],AA(:,1),AA(:,2)))';
catch
 for i=1:size(AA,1)
     bb(i)=DD(AA(i,1),AA(i,2));
 end;
end;


clear('DD');

% Reduce the number of forced vectors
ii=[1:ForceC]';
jj=zeros(1,size(AA,1));
jj(ii)=1; jj=find(jj==0);

jj1=jj(find(jj<=ForceC));
jj2=jj(find(jj>ForceC));
jj2=jj2(randperm(length(jj2)));
jj1=jj1(randperm(length(jj1)));

% Construct constraint matrix

corder=[ii;jj1';jj2'];
AA=[AA(corder,:)];
bb=bb(corder);
ForceC=length(ii);
clear('temp','jj1','jj2','jj','ii');


Const = max(round(pars.warmup*size(AA,1)),ForceC);

[A,b,AA,bb] = getConstraints(AA,QFull,bb,B,Const,pars);

Qt=sum(QFull,1)'*sum(QFull,1); % Add sum-to-zero constraint
A=[Qt(:)';A];
b=[0;b];


Kneigh=k;


clear('k');
solved=0;
fprintf('done\n\n');

while(solved==0)
 fprintf('Size of A: %ix%i \n\n\n',size(A));

 c=0-vec(QFull'*QFull);

flags.s=B;
flags.l=size(A,1)-1;  
A=[[zeros(1,flags.l); speye(flags.l)] A];


 if(pars.penalty)
  c=[ones(ForceC,1).*max(max(c));zeros(flags.l-ForceC,1);c];
 else
  c=[zeros(ForceC,1);zeros(flags.l-ForceC,1);c];  
 end;

 fprintf('Omit %i constraints\n',TotalConstraints-size(A,1));

 % Solve SDP
 switch(pars.solver)
  case{0},
   options.maxiter=pars.maxiter;
   [x d z info]=csdp(A,b,c,flags,options);
   L=mat(x(flags.l+1:flags.l+flags.s^2));
  case{1},        
   [k d info]=sedumi(A,b,c,flags);
   info=info.numerr;
   L=mat(k(end-flags.s^2+1:end)); 
  case{2},
   fprintf('converting into SQLP...');
   Ap=A;bp=b;cp=c;
   [blk,A,c,b]=convert_sedumi(A',b,c,flags);
   fprintf('DONE\n');
   if(exist('L'))  
     fprintf('Initializing ...');
     % Initialize with input points
     [X0,y0,Z0]=infeaspt(blk,A',c,b); 
     X0{length(X0)}=L+speye(B).*0.001;

     fprintf('DONE\n');
     [obj,Lt,d,z,info]=sqlp(blk,A,c,b,{},X0,y0,Z0);
   else
     [obj,Lt,d,z,info]=sqlp(blk,A,c,b);
   end;
   info=info(1);
   L=Lt{length(Lt)};
   info=0;
   clear('A','b','c');
   A=Ap;b=bp;c=cp;
 end;
  
 % Check Constraints
 solved=(isempty(AA));
 A=A(:,flags.l+1:end);
 xx=L(:);
 if(size(AA,1))
   Aold = size(A,1);
   total=0;
   while size(A,1)-Aold<Const & ~isempty(AA)
     [newA,newb,AA,bb] = getConstraints(AA,QFull,bb,B,Const,pars);
     jj=find(newA*xx-newb>pars.margin*abs(newb));
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

   fprintf('Total violated constraints:%i\n',total);
   if(total==0) solved=1;end;
 else
   solved=1;  
 end;

 if(solved==1 & pars.maxiter<100) pars.maxiter=100; end;
end;


% Generate Output
[V D]=eig(L);
V=V*sqrt(D);
Y=(V(:,end:-1:1))';
Y=Y*QFull';

Y=Y(:,original);

details.k=Kneigh;
details.D=diag(D);
details.info=info;
details.pars=pars;
details.dual=d;
details.QFull=QFull(original,:);
details.QFull=details.QFull(oi,:);
details.landmarks=gi(1:B);
details.B=B;
details.L=L;
details.gi=gi;
details.time=toc;
details.constraint=size(A,1);
details.TotalConstraints=TotalConstraints;
Y=Y(:,oi);













function [Q,mui]=getQ(B,LL,K,DD,pars);

N=size(DD,1);
mui=1:B;
clear('neighbors');
clear('distances');

[sorted,index]=sort(DD);
neighbors=index(2:LL+1,:);
clear('sorted');  
clear('index');

if(~isfield(pars,'G'))

 fprintf('Computing Gram Matrix  \n');
 try
   if(N>=2000)
     error('Other method is faster for large data sets!\n');  
   end;
 fprintf('Trying fast full-matrix method ...');

 H=speye(N)-1/N*ones(N);
  G=-0.5*H*DD*H;
  G=(G+G')./2;
 clear('H');
 fprintf('done\n');
 catch
 clear('G');

 NN=sparse([],[],[],N,N,nnz(neighbors));
 for i=1:N
  NN(neighbors(:,i),i)=1;    
 end;
 NN=max(NN,NN');
 NN=NN+NN'*NN;
 NN=triu(NN); 

 fprintf('Computing sparse Gram Matrix by hand ...');   
  G=sparse([],[],[],N,N,LL*B);
  Ds=repmat(-sum(DD,2)./N,1,max(sum(NN>0))); 
  for i=1:N
    n=find(NN(:,i));
     v=Ds(:,1:length(n))+DD(:,n);
    v=-0.5*(sum(-v./N,1)+v(i,:));
    G(i,n)=v;
    G(n,i)=v';
  end;
 fprintf('done\n');
 end;
else
 G=pars.G;   
 fprintf('Taking pre-computed Gram Matrix!\n');
 pars.G=0;
end;

tol=1e-4; 
QFull = sparse([],[],[],B,N);
for i=1:N
  ne=neighbors(:,i);
  C=repmat(G(i,i),LL,LL)-repmat(G(i,ne),LL,1)-repmat(G(ne,i),1,LL)+G(ne,ne);
  C = C + tol*sum(DD(ne,i))*speye(LL)/LL; % REGULARIZATION
  invC = inv(C);
  QFull(ne,i) = sum(invC)'/sum(sum(invC));
end;


clear('DD');
M=eye(N);
for i=1:N 
  j = neighbors(:,i);
  w = QFull(j,i);
  M(i,j) = M(i,j) - w';
  M(j,i) = M(j,i) - w;
  M(j,j) = M(j,j) + w*w';
end;


l=N-B;
k=B;

clear('neighbors','QFull','invC','w','j','G','C','w');

Q=-(M(B+1:end,B+1:end))\M(B+1:end,1:B);
Q=[eye(B);Q]; 















function [A,b,AAomit,bbomit] = getConstraints(AA,QFull,bb,B,Const,pars)
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
    Q=QFull(ii,:)'*QFull(ii,:)-2.*QFull(jj,:)'*QFull(ii,:)+QFull(jj,:)'*QFull(jj,:);
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




function v=vec(M);

v=M(:);


function M=mat(C);

r=round(sqrt(size(C,1)));
M=reshape(C,r,r);