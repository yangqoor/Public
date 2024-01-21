function zM=zero_pad(M,zp1,zp2);
if (nargin==2)
    zp2=zp1;
end

[n,m,k]=size(M);
zM=zeros(n+2*zp1,m+2*zp2,k);
zM(zp1+1:end-zp1,zp2+1:end-zp2,:)=M;
