function [Kwhiten,A]=whiteningFilter(xs,siz)
% calculate the zero phase whitening filter using PCA
% xs is a npatches*npixels _in_patch matrix where each row is a patch
% siz is the size of the patch (e.g. [5 5])
cov=xs'*xs;
[uu,ss,vv]=svd(cov);
dd=diag(ss);
D=diag(sqrt(1./dd));
A=uu*D*uu';
Kwhiten=reshape(A(round(prod(siz)/2),:),siz);
Kwhiten=Kwhiten';
Kwhiten=Kwhiten-mean(Kwhiten(:));
 Kwhiten=Kwhiten/norm(Kwhiten(:));
 