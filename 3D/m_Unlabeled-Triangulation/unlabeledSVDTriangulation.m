function Mtriang = unlabeledSVDTriangulation(B,N)
[~,n]=size(B);
A=cellfun(@twidleMatrix,B,'UniformOutput', false);
Nvectors=zeros(6,n);
for i=1:n
    Nzwischen=N{i};
    Nvectors(:,i)=Nzwischen(tril(true(size(Nzwischen))));
end
[kernelProjB, r]=svdTriangulation(A,Nvectors);
for i=1:(r+1)
    M{i}=vecToSymmetric4x4Matrix(kernelProjB(:,i));
end
if (r+1)==2
   focal_point1=null(B{1});
   focal_point2=null(B{2});
   M0=focal_point2*focal_point1'+focal_point1*focal_point2'; M0=M0/M0(4,4); 
   Mtriang=unlabeledTwoViewCase(M,M0);
else
    [u,d,v]=svd(M{1});
    d(3:4,3:4)=0;
    Mtriang=u*d*v';
end

