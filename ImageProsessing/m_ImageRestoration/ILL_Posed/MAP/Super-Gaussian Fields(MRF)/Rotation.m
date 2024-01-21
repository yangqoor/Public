function [w,u]=Rotation(x,xcov,pis,prob,orthVect,j)
% find best projection using iterated PCA
% here we get as input a basis matrix, and learn eigenvectors w=basis*u
% where u is an orthogonal matrix. This makes sure that log Z(w) = log Z(basis)

%
if ~exist('orthVect')
    orthVect=0;
end
nIter=1;

xs = im2col(x, [15,15], 'sliding');
% Kwhiten=whiteningFilter(xs',[3 3]);
% basis1=makeBasis(Kwhiten,1);
Kwhiten=equivalentFilter(prob.J,[15,15]);
basis1=makeBasis(Kwhiten,2);

[uu,ss,vv]=svd(orthVect*orthVect');
I=find(diag(ss)<0.0000000001);
L=uu(:,I);


Tcovx =  im2col(xcov, [15,15], 'sliding');
for i=1:nIter

    weight=pis(:)*0.5;
    
    W=sparse(1:length(weight),1:length(weight),weight);

    cov=xs*W*xs' + diag(sum(Tcovx*W,2));
     
   
    cov2=basis1'*cov*basis1;
   
    [uu,ss,vv]=svd(L'*cov2*L);
    u=L*uu(:,end);
  
    w=reshape(basis1*u,15,15);
    
    
end

