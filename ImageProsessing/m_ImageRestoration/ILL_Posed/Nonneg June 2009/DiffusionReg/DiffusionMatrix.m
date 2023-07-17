  function L = DiffusionMatrix(nx,ny,D)
  
%  Compute matrix L corresponding to the discretization of the
%  2-D negative Laplacian with homogeneous Dirichlet BC.
  
  ex = ones(nx,1);
  Dx_1d = spdiags([-ex,ex],[0 1],nx,nx);
  Dx_1d(nx,1) = 1;
  
  ey = ones(ny,1);
  Dy_1d = spdiags([-ey,ey],[0 1],ny,ny);
  Dy_1d(ny,1) = 1;
  
  Ix    = speye(nx,nx);
  Iy    = speye(ny,ny);
  Dx_2d = kron(Iy,Dx_1d);
  Dy_2d = kron(Dy_1d,Ix);
  
  L = Dx_2d'*D*Dx_2d + Dy_2d'*D*Dy_2d;
  

