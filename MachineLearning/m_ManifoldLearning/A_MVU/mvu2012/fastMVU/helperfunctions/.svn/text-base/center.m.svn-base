function x=center(x,dim);
% function x=center(x,dim);
% x=x-repmat(mean(x,2),1,size(x,2));

if(nargin<2) dim=2;end;

if(dim==2)
 x=x-repmat(mean(x,dim),1,size(x,2));
else
 x=x-repmat(mean(x,dim),size(x,dim),1);
end;

