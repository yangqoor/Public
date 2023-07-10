function fring = compute_face_ring(face)

% compute_face_ring - compute the 1 ring of each face in a triangulation.
%
%   fring = compute_face_ring(face);
%
%   fring{i} is the set of faces that are adjacent
%   to face i.
%
%   Copyright (c) 2004 Gabriel Peyre

% the code assume that face is of size (3,nface)
if size(face,2)>size(face,1)
    face = face';
end

nface = size(face,1);
nvert = max(max(face));

for i=1:nface
    face(i,:) = sort(face(i,:));
end

edges = zeros(3*nface,2);

edges( 1:nface, : ) = face(:,1:2);
edges( (nface+1):2*nface, : ) = face(:,2:3);
edges( (2*nface+1):3*nface, : ) = face(:,[1,3]);

for i=1:nface
    fring{i} = [];
end

for i=1:3*nface
    e = edges(i,:);
    I = find(edges(:,1)==e(1) & edges(:,2)==e(2));
    if length(I)==2
        f1 = mod( I(1)-1, nface)+1;
        f2 = mod( I(2)-1, nface)+1;
        fring{f1} = [fring{f1}, f2];
        fring{f2} = [fring{f2}, f1];
        edges(I,:) = rand(length(I),2);
    end
end

return;

return;
h = waitbar(0,'Computing Face 1-ring');
for i=1:nface
    waitbar(i/nface);
    fring{i} = [];
    for j=1:3
        j1 = j;
        j2 = mod(j,3)+1;
        v1= face(i,j1);
        v2= face(i,j2);
        % test if another face share the same vertices
        f = [];
        for i1=1:nface 
            for a=1:3
                if face(i1,a)==v1 && i1~=i
                    for b=1:3
                        if face(i1,b)==v2
                            % add to the ring
                            fring{i} = [fring{i}, i1];
                        end
                    end
                end
            end
        end
        
    end
end
close(h);