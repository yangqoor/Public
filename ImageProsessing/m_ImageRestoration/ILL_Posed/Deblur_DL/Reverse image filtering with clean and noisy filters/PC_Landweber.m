function [L, E] = PC_Landweber(F, y, options)
% Phase corrected Landweber iterations
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
    
    L = L + tau.*real(ifft2((fft2(y)./(H+eps)-fft2(L)).*abs(H))) + mu .* curv(L);
    e = img_norm(y - F(L));
    E = [E; e];
end

end