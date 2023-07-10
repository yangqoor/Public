function result=connectedG(DD);

% result = connecteddfs (DD)
%
% DD sparse graph
%
% Returns: result = 1 if connected 0 if not connected


N=length(DD);
rep = [1:N]';
for i=1:N
    DD(:,i)=(DD(:,i)~=0).*rep;
end;
checked=[1 zeros(1,N-1)]==1;

oldnnz=0;
while((nnz(checked)<N) & nnz(checked)>oldnnz)
 oldnnz=nnz(checked);
 next=any(DD(checked,:),1);
 checked=or(next,checked);
end;

result=nnz(checked)==N;

