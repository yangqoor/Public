function [T, E] = Tao_orig(F, y, options)
% Original defiltering scheme of Tao et al.

options.null = 0;
maxiter = getoptions(options, 'maxiter', 10);

T = F(y);

E = [];
e = img_norm(y - F(T));
E = [E; e];

for i=1:maxiter
    T = T + (y-F(T));
    e = img_norm(y - F(T));
    E = [E; e];
end

end

