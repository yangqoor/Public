% function to compute energy of the graph defiend on image lattice
function E=imgraphen(IDX,CO,CM_h,CM_v)
if length(size(IDX))==2
    [nh,nw]=size(IDX);
    IDX=reshape(IDX,[1 nh nw]);
end
%E=CO(IDX);
[nh,nw]=size(squeeze(IDX));
for i=1:nh
    for j=1:nw
        E(i, j) = CO(IDX(1, i, j), i, j);
    end
end
E=sum(E(:));
IDX=squeeze(IDX);

for i=1:nh
    for j=1:nw
        % horizontal energy
        p=IDX(i,j);
        if j<nw
            q=IDX(i,j+1);
            E=E+CM_h(p,q,i,j);
        end
        if i<nh
            q=IDX(i+1,j);
            E=E+CM_v(p,q,i,j);
        end
    end
end