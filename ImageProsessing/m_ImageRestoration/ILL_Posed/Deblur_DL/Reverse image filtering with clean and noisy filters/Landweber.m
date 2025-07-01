function [L, E] = Landweber(F, y, options)
% Landweber iterations
options.null = 0;
tau = getoptions(options, 'tau', 1.0);
maxiter = getoptions(options, 'maxiter', 1000);
mu = getoptions(options, 'mu', 0.0);

L = y;

E = [];
e = img_norm(y - F(L));
E = [E; e];

for i=1:maxiter
    H = fft2(F(L))./(fft2(L)+eps);
        
    L = L + tau.*real(ifft2(conj(H).*(fft2(y-F(L))))) + mu .* curv(L);
    e = img_norm(y - F(L));
    E = [E; e];
end

end
