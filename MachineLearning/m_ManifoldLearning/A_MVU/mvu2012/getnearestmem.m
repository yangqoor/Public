function neighbors = getnearestmem(X,KK,av);
% function neighbors = getnearestmem(X,KK);
%
% finds nearest neighbors while utilizing the available memory
  
[D,N] = size(X);

if(nargin<3)
  % magic number, substitute by a larger number if you have a lot
  % of ram
  av=6000000/N;
end;

neighbors=zeros(KK,N);

S = whos;

%av=floor(sqrt(getmem(10,N)^2-KK*N));
% getmem only works well on some platforms
% might speed up things, but might also slow down 
%

av=av./4;

blck=av;

blck=min(ceil(round(N/2)),blck);
if(blck<1) blck=1;end;

if blck<N
  for ii=1:blck:N
    if ii+blck<N
      part=X(:,ii:ii+blck-1);
    else
      part=X(:,ii:end);
    end;
    dist=distance(part,X);
    [sorted,index]=sort(dist');
    neighbors(:,ii:min(ii+blck-1,N)) = index(2:1+KK,:);

  end;
else
  dist=distance(X);
  [sorted,index]=sort(dist);
  neighbors = index(2:1+KK,:);
end;


    


function a=getmem(Acc,N);
% functdion a=getmem(Acc,N)
%
% evaluates the amount of free memory:
%
% zeros(a,N) is definitely still possible
% zeros(a+Acc,N) will crash
%

if(nargin<1), Acc=100;end;
a=1;
b=ceil(40000/Acc);

while(a~=b-1)
    c=ceil((a+b)/2);
%    disp([a b c].*Acc);
    try 
        if(nargin<2)
            N=c*Acc;
        end;
        zeros(c*Acc,N);
        a=c;
    catch
        b=c;
    end;
end;

a=a*Acc;


