function lyap = lyapunov(funfnc, st, kkmax, x, ode)

n=length(x);
%
%  Set exponents and sums zero at start
%
ex=zeros(n,1);
sum=zeros(n,1);
%
%  Set up tangent vectors as [three] columns of identity matrix
%
u=eye(n);
tinit=0;
%
% Loop kmax times over (integration for st then GS orthog)
%
for kindex=1:kkmax
  tfinal=tinit+st;
  %
  %   Create long column vector containing phase point and tangent vectors
  %
  var=[x;reshape(u,n*n,1)];
  %
  % Use ode45 with rhs function to integrate phase point & tangent
  % vectors over time st before doing Gram-Schmidt orthogonalisation 
  %
  %%[t,xx]=ode1(funfnc,[tinit,tfinal],var); % Solve all ODEs  
  xx=ode(funfnc,[tinit,tfinal],var); % Solve all ODEs  
  ss=size(xx);
  var=xx(ss(1),:)'; 
  clear t xx
  %
  % Recover new phase point and tangent vectors (put latter as matrix again)
  %
  x=var(1:n);
  dx=reshape(var(n+1:length(var)),n,n);
    %
    %  Gram-Schmidt orthogonalise tangent vectors (see eg Alligood et al p199)
    %
    for i=1:n
      v(:,i)=dx(:,i);
      %
      % form dot product of ith column of v with jth column of u
      %
      for j=1:i-1
        dotp=v(:,i)'*u(:,j);
        v(:,i)=v(:,i)-dotp*u(:,j);
      end
      veclen=v(:,i)'*v(:,i);
      veclen=sqrt(veclen);
      u(:,i)=v(:,i)/veclen;
      %
      %  Accumulate sum of logs and divide by current time for LEs
      %
      sum(i)=sum(i)+log(veclen);
      ex(kindex,i)=sum(i)/(kindex*st);
    end
  it(kindex)=tfinal;
  tinit=tfinal;
end
%
% Plot convergence of LEs
%
plot(it,ex)
sex=size(ex);

% return lyap's at the end
lyap = ex(sex(1),:);
