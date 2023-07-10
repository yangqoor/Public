function [vertex1,face1] = subdivide_sphere(vertex,face,nsub)

% subdivide - perform a 1:4 subdivision.
%   Subdivide each triangle into 4 smaller triangles, 
%   and then project on the sphere whith radius one.
%   
%   [vertex1,face1] = subdivide(vertex,face,nsub);
%
%   Copyright (c) 2004 Gabriel Peyr�

if nargin<2
    error('Not enough arguments');
end
if nargin==2
    nsub=1;
end

if size(vertex,1)<size(vertex,2)
    vertex = vertex';
end
if size(face,1)<size(face,2)
    face = face';
end


if nsub==0
    vertex1 = vertex;
    face1 = face;
    return;
end

if nsub>1
    % special case for multi-subdivision
    vertex1 = vertex;
    face1 = face;
    for i = 1:nsub
         [vertex1,face1] = subdivide_sphere(vertex1,face1,1);
    end
    return;    
end

nvert = max(max(face));
[vertex1,face1] = subdivide(vertex,face);
nvert1 = max(max(face1));

% project new vertices
for i=(nvert+1):nvert1
    vertex1(i,:) =  vertex1(i,:)/norm(vertex1(i,:), 'fro');
end