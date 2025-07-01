function [kw, E] = aL(F, y, options)
% approximate non-linear Landweber 
options.null = 0;
%lam = getoptions(options, 'lam', 1.0);
maxiter = getoptions(options, 'maxiter', 100);
p = getoptions(options, 'p', 0.0);

kw = y;

E = [];
e = img_norm(y - F(kw));
E = [E; e];

for n=1:maxiter
    hp = y-F(kw);
    hp = hp(end:-1:1,end:-1:1,:);
    d = (F(kw+hp)-F(kw-hp))/2;
    d = d(end:-1:1,end:-1:1,:);
    
    % step-size
    lam = 1.0/(n)^(p);
    
    kw = kw + lam*d;
    
    e = img_norm(y - F(kw));
    E = [E; e];
end

end
