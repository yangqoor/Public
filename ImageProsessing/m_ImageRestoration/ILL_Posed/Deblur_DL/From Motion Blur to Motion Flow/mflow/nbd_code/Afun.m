
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = Afun(x,bmag, bori, beta, tflag)

[m n] = size(bmag); 
x = reshape(x, m, n);
%if (strcmp(tflag,'transp') | strcmp(tflag,'notransp'))
    Gx = [diff(x, 1, 2), x(:,n-1) - x(:,n)]; 
    Gy = [diff(x, 1, 1); x(m-1,:) - x(m,:)]; 

    Gxx = -[Gx(:,2) - Gx(:, 1), -diff(Gx,1,2)]; 
    Gyy = -[Gy(2,:) - Gy(1, :); -diff(Gy,1,1)]; 

    Kx = motionBlurConv(x, bmag, bori);
    Kxx = motionBlurConv_mirror(Kx, bmag, bori);

    y = Kxx - beta * (Gxx + Gyy);
%end
y = y(:);