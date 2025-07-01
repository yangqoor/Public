function [N, E] = NA_Landweber(F, y, options)
% Nesterov-accelerated Landweber iterations
options.null = 0;
tau = getoptions(options, 'tau', 1.0);
maxiter = getoptions(options, 'maxiter', 1000);
mu = getoptions(options, 'mu', 0.0);

N = y;
N_prev = N;

E = [];
e = img_norm(y - F(N));
E = [E; e];

for i=1:maxiter
    z = N+(i-1)/(i+2)*(N-N_prev);
    N_prev = N;

    H = fft2(F(z))./(fft2(z)+eps);
    yerror = y-F(z);
            
    N = z + tau.*real(ifft2(conj(H).*(fft2(yerror)))) + mu.*curv(N);
    
    e = img_norm(y - F(N));
    E = [E; e];
end

end
