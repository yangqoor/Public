  function T = bttb(t)
  
%  Construct block Toeplitz-Toeplitz block (BTTB) matrix T from array t.

  [nnx,nny] = size(t);
  if (mod(nnx,2)==0 | mod(nny,2)==0)
    fprintf('\n *** Row and column dimensions of input t must be odd.\n');
    return
  end
  
  nx = ceil(nnx/2);  %  nnx = 2*nx - 1
  ny = ceil(nny/2);  %  nny = 2*ny - 1
  N = nx*ny;         %  T is N X N
  T = spdiags(zeros(N,1), 0, N,N);
  
  for j = 1:ny
    tj = t(:,j);
    if norm(tj) > 0
      Tj = my_toeplitz(tj);
      xindex = [1:j];
      yindex = [ny-j+1:ny];
      for k = 1:j
        i0 = (xindex(k) - 1)*nx;
        j0 = (yindex(k) - 1)*nx;
        T(i0+1:i0+nx,j0+1:j0+nx) = Tj;
      end
    end
  end
  
  for j = ny+1:nny
    tj = t(:,j);
    if norm(tj) > 0
      Tj = my_toeplitz(tj);
      xindex = [j-ny+1:ny];
      yindex = [1:nny-j+1];
      for k = 1:nny-j+1
        i0 = (xindex(k) - 1)*nx;
        j0 = (yindex(k) - 1)*nx;
        T(i0+1:i0+nx,j0+1:j0+nx) = Tj;
      end
    end
  end
    
