function [DD,AA,b]=dissimilar(x,epsilon,knn,noise);
% function [DD,AA,b]=dissimilar(x,epsilon,knn,noise);
% 
% Computes a sparse similarity matrix with the given epsilon ball or knn rule
% 
% e.g. 
% D=disssimilar(x,(0.3)^2);  % generates sparse NN-distance matrix of columns of x (with epsilon ball of squared distance (0.3)^2)
% D=disssimilar(x,inf,13);   % generates sparse NN-distance matrix of columns of x (by connecting k=13 nearest neighbors)
%
% the last parameter "noise" corrupts the distances with random noise
%
% copyright by Kilian Q. Weinberger, 2006

fprintf('Computing dissimilarity matrix\n');
if(nargin<3) knn=inf;end;
if(nargin<4) noise=0;end;
  
if(round(knn)~=knn)
 error('The second input paramter must be an integer. Thanks. ');
end;

x=center(x);

N=size(x,2);

% estimate rough number of neighbors
dd=distance(x(:,1),x);
k=min(length(find(dd<epsilon)),knn);
%nck=nchoosek(1:(K+1),2);
AA=zeros(N*k,2);
b=zeros(N*k,1);
pos3 = 1;
BB=500;
for j=1:BB:N
   ind=j:min(j+BB-1,N);  
   dd=distance(x,x(:,ind));   
   %% ADD NOISE
%   dd=dd.*((1+randn(size(dd)).*noise).^2);
   %%
   progressbar(j,N);
   for ii=1:length(ind)
    ne=find(dd(:,ii)<epsilon);
    if(knn<length(ne))
     [temp,itemp]=mink(dd(ne,ii),knn);
     ne=ne(itemp);
    end;
    K=length(ne);
    js=ones(K,1).*ind(ii);
    ks=ne;
    AA(pos3:pos3+length(js)-1,:)=sort([js ks]')';
    b(pos3:pos3+length(js)-1)=dd(ne,ii);
    pos3 = pos3 + length(js);
    if(pos3>size(AA,1) & ind(ii)<N)
      [AA,icut]=unique(AA,'rows');
      b=b(icut);
      pos3=size(AA,1)+1;
 
      newzeros=round(N/(ind(ii))*pos3);
      b=[b;zeros(newzeros,1)];
      AA=[AA;zeros(newzeros,2)];
      fprintf('.');
    end;
   end;
end;
progressbar(N,N);fprintf('\n\n');
[AA,icut]=unique(AA,'rows');
b=b(icut);
icut2=find(AA(:,1)~=AA(:,2)); % cut out distances between points
                              % and themselves
AA=AA(icut2,:);
b=b(icut2);
if(AA(1)==0) AA=AA(2:end,:);b=b(2:end);end;%erase the [0 0] entry
TotalConstraints=size(AA,1);
DD=sparse(AA(:,1),AA(:,2),b,N,N);
DD=DD+DD';














 






%%% SIMPLE BUT USEFUL UTIL FUNCTIONS

function neighbors=getneighborsUDD(DD,K);
ne=getneighborsDD(DD,K);
N=length(DD);

for i=1:N
    neighbors{i}=[];
end;

for i=1:N
 neighbors{i}=merge(sort(neighbors{i}),sort(ne(:,i)));
 for j=1:K
    neighbors{ne(j,i)}=merge(neighbors{ne(j,i)}, i);
 end;
end;



function result=merge(x,y);
result=unique([x(:);y(:)]);


function v=vec(M);
v=M(:);


function k=neighborsUDD(DD,K);
N=length(DD);
if(nargin<2)
    K=2;
end;
k=K;
while(k<N & (1-connectedUDD(DD,k)))
    k=k+1;
    fprintf('Trying K=%i \n',k);
end;



function result=connectedUDD(DD,K);
% result = connecteddfs (X,K)
%
% X input vector
% K number of neighbors
%
% Returns: result = 1 if connected 0 if not connected

if(nargin<2)
    fprintf('Number of Neighbors not specified!\nSetting K=4\n');
    K=4;    
end;
N=length(DD);


ne=getneighborsUDD(DD,K);

 
maxSize=0;
for i=1:N
    if(length(ne{i})>maxSize) maxSize=length(ne{i});end;
end;
neighbors=ones(maxSize,N);
for i=1:N
    neighbors(1:length(ne{i}),i)=ne{i};    
end;
oldchecked=[];
checked=[1];

while((size(checked)<N) & (length(oldchecked)~=length(checked)))  
 next=neighbors(:,checked);
 next=transpose(sort(next(:)));
 next2=[next(2:end) 0];
 k=find(next-next2~=0);
 next=next(k);

 oldchecked=checked; 
 checked=neighbors(:,next(:));
 checked=transpose(sort(checked(:)));
 checked2=[checked(2:end) 0];
 k=find(checked-checked2~=0);
 checked=checked(k);
end;
result=(length(checked)==N);



function X = mat(x,n)
 if nargin < 2
   n = floor(sqrt(length(x)));
   if (n*n) ~= length(x)
     error('Argument X has to be a square matrix')
   end
 end
 X = reshape(x,n,n);

 
 
 
function neighbors=getneighborsDD(DD,K);
N=length(DD);
[sorted,index] = sort(DD);
neighbors = index(2:(1+K),:);



function progressbar(n,N,s2);
LE=10;
persistent oldp;
if(isempty(oldp)) oldp=11;end;
p=floor(n/N*LE);
if(p~=oldp)
 if(~exist('s2')) s2='';end;
 ps='..........';
 ps(1:p)='*';
 fprintf('\rProgress:[%s]%s',ps,s2);
 oldp=p;
end;     
