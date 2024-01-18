function E = getTVEnergy(f)

% compute total variation
fyforw = f([2:end end],:,:)-f;
fxforw = f(:,[2:end end],:)-f;

Q = sqrt(fyforw.^2 + fxforw.^2 );
E = sum(Q(:));