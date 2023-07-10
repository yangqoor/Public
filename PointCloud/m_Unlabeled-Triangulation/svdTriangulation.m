function [kernel, r ] = svdTriangulation(A,x)
[~,worldDim]=size(A{1});
Asigma=cat(1,A{:});
x=num2cell(x',2);
xEmbed=blkdiag(x{:})';
B=[Asigma xEmbed];
r=worldDim-rank(Asigma);
[u,d,v]=svd(B);
d(:,end-r:end)=0;
kernel=null(u*d*v');
end

