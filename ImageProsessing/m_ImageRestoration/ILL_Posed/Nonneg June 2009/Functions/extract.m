  function B = extract(A,nx,ny)
  
%  B = extract(A,nx,ny);
%
%  Extract nx X ny submatrix B from center of matrix A.

  [Nx,Ny] = size(A);
  if nx==Nx & ny==Ny    % A and B are same size. No extraction needed.
    B = A;
  else
    ixmin = ceil((Nx-nx)/2) + 1;
      ixmax = ixmin + nx - 1;
    iymin = ceil((Ny-ny)/2) + 1;
    iymax = iymin + ny - 1;
    B = A(ixmin:ixmax,iymin:iymax);
  end