  function C = bccb(c)
  
%  Construct block Circulant-Circulant block (BCCB) matrix C from array c.

  [nx,ny] = size(c);
  N = nx*ny;         %  C is N X N
  C = zeros(N,N);

  %  Main diagonal blocks.
  
  C1 = circulant(c(:,1));
  for k = 1:ny
    i0 = (k-1)*nx;
    C(i0+1:i0+nx,i0+1:i0+nx) = C1;
  end
  
  %  Off diagonal blocks.
  
  for j = 2:ny
    cj = c(:,j);
    Cj = circulant(cj);
    
    %  Lower triangle.
    
    xindex = [j:ny];
    yindex = [1:ny-j+1];
    for k = 1:ny-j+1
      i0 = (xindex(k) - 1)*nx;
      j0 = (yindex(k) - 1)*nx;
      C(i0+1:i0+nx,j0+1:j0+nx) = Cj;
    end
    
    %  Upper triangle.
    
    xindex = [1:j-1];
    yindex = [ny-j+2:ny];
    for k = 1:j-1
      i0 = (xindex(k) - 1)*nx;
      j0 = (yindex(k) - 1)*nx;
      C(i0+1:i0+nx,j0+1:j0+nx) = Cj;
    end
    
  end
    
