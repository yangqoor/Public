  function L = laplacian(nx,ny)
  
%  Compute matrix L corresponding to the discretization of the
%  2-D negative Laplacian with homogeneous Dirichlet BC.
  
  N = nx * ny;
  
  Adiag = 4*ones(N,1);
  Asubs = -ones(N,1);
  Asub1 = -ones(N,1);
  for i=1:ny
    Asub1(i*nx)=0;
%    Adiag((i-1)*nx+1) = Adiag((i-1)*nx+1) - 1;  %  Neumann BC
%    Adiag(i*nx) = Adiag(i*nx) - 1;
  end
  Asuper1 = -ones(N,1);
  for i=0:ny-1
    Asuper1(i*nx+1)=0;
  end
  
%  Adiag(1:nx) = Adiag(1:nx) - ones(nx,1);       %  Neumann BC
%  Adiag(N-nx+1:N) = Adiag(N-nx+1:N) - ones(nx,1);
  
  L = spdiags([Asubs,Asub1,Adiag,Asuper1,Asubs],[-nx -1 0 1 nx],N,N);
  

