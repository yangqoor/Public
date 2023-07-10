function F=gravy_nev1(z0,H,X,PHI,phi,U);
% невязка вычисленной и заданной силы тяжести
W=potenz1(z0,H,X,PHI,phi);
F=norm(W-U)/norm(U);