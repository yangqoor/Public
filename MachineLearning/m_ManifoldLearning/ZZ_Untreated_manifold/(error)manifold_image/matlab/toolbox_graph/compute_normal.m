function normal = compute_normal(vertex,face)

% compute_normal - compute the normal at each vertex
%   of a triangulation, using mean of the faces normals.
%
%   normal = compute_normal(vertex,face);
%
%   Copyright (c) 2004 Gabriel Peyré

if size(face,2)~=3
    face=face';
end
if size(face,2)~=3
    error('face is not of correct size');
end

if size(vertex,2)~=3
    vertex=vertex';
end
if size(vertex,2)~=3
    error('vertex is not of correct size');
end

nface = size(face,1);
nvert = size(vertex,1);
normal = zeros(nvert,3);

for i=1:nface
    f = face(i,:);
    % compute the normal to the face
    n = cross( vertex(f(2),:)-vertex(f(1),:),vertex(f(3),:)-vertex(f(1),:) );
    n = n/norm(n,'fro');
    for j=1:3
        normal( f(j),: ) = normal( f(j),: ) + n;
    end
end

% normalize
d = sqrt( sum( normal.^2, 2 ) );
I = find(d>eps);
normal(I,1) = normal(I,1)./d(I);
normal(I,2) = normal(I,2)./d(I);
normal(I,3) = normal(I,3)./d(I);