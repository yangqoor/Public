function faces = perform_faces_reorientation(vertex,faces)

% perform_faces_reorientation - reorient the faces with respect to the center of the mesh
%
%   faces = perform_faces_reorientation(vertex,faces);
%
%   Copyright (c) 2006 Gabriel PeyrŽ

% compute the center of mass of the mesh
G = mean(vertex,2);


if size(vertex,1)>size(vertex,2)
    vertex = vertex';
end
if size(faces,1)>size(faces,2)
    faces = faces';
end
nverts = size(vertex,2);
nfaces = size(faces,2);


% center of faces
Cf = (vertex(:,faces(1,:)) + vertex(:,faces(2,:)) + vertex(:,faces(3,:)))/3;
Cf = Cf - repmat(G,[1 nfaces]);
% normal to the faces
V1 = vertex(:,faces(2,:))-vertex(:,faces(1,:));
V2 = vertex(:,faces(3,:))-vertex(:,faces(1,:));
N = [V1(2,:).*V2(3,:) - V1(3,:).*V2(2,:) ; ...
    -V1(1,:).*V2(3,:) + V1(3,:).*V2(1,:) ; ...
     V1(1,:).*V2(2,:) - V1(2,:).*V2(1,:) ];
% dot product
s = sign(sum(N.*Cf));
% reverse faces
I = find(s>0);
faces(:,I) = faces(3:-1:1,I); 
