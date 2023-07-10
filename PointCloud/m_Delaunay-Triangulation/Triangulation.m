% Justin Casali
function coordinates = Triangulator(xa, ya, ta, xb, yb, tb)
% returns the coordinates for the triangulated point
% N.E. is positive, angle measured in degrees off the northern axis
    
    ta = mod(ta + 90, 360);
    tb = mod(tb + 90, 360);
    
    A_loc = [xa, ya];
    B_loc = [xb, yb];

    A_dir = [cosd(ta) sind(ta)];
    B_dir = [cosd(tb) sind(tb)];

    AB = B_loc - A_loc;
    BA = A_loc - B_loc;

    a = acos(dot(A_dir, AB/norm(AB)));
    b = acos(dot(B_dir, BA/norm(BA)));
    c = pi - a - b;
    
    A_opp = sin(a) * norm(AB) / sin(c);
    B_opp = sin(b) * norm(BA) / sin(c);

    A = B_opp * A_dir;
    B = A_opp * B_dir;

    coordinates = (A + A_loc + B + B_loc) / 2;
    
end
