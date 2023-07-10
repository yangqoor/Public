function path = compute_discrete_geodesic(D,x)

% compute_discrete_geodesic - extract a discrete geodesic in 2D and 3D
%
%   path = compute_discrete_geodesic(D,x);
%
%   Same as extract_path_xd but less precise and more robust.
%
%   Copyright (c) 2007 Gabriel Peyre


nd = 2;
if size(D,3)>1
    nd = 3;
end

x = x(:);
path = round(x(1:nd));

% admissible moves
if nd==2
    dx = [1 -1 0 0];
    dy = [0 0 1 -1];
    dz = [0 0 0 0];
    d = cat(1,dx,dy);
    vprev = D(x(1),x(2));
else
    dx = [1 -1 0 0 0 0];
    dy = [0 0 1 -1 0 0];
    dz = [0 0 0 0 1 -1];
    d = cat(1,dx,dy,dz);
    vprev = D(x(1),x(2),x(3));
end

s = size(D);
while true
    x0 = path(:,end);
    x = repmat(x0,1,size(d,2))+d;
    if nd==2
        I = find(x(1,:)>0 & x(2,:)>0 & x(1,:)<=s(1) & x(2,:)<=s(2) );    
    else
        I = find(x(1,:)>0 & x(2,:)>0 & x(3,:)>0 & x(1,:)<=s(1) & x(2,:)<=s(2) & x(3,:)<=s(3) );
    end
    x = x(:,I);
    if nd==2
        I = x(1,:) + (x(2,:)-1)*s(1);
    else
        I = x(1,:) + (x(2,:)-1)*s(1) + (x(3,:)-1)*s(1)*s(2);
    end
    [v,J] = min(D(I));
    x = x(:,J);
    if v>vprev
        return;
    end
    vprev = v;
    path(:,end+1) = x;
end