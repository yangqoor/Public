function [D, E] = Dong(F, y, options)
% Dong et al. 2019
options.null = 0;
maxiter = getoptions(options, 'maxiter', 2);

D = y;

E = [];
e = img_norm(y - F(D));
E = [E; e];

for i=1:maxiter
    D = real(ifft2(fft2(D).*fft2(y)./(fft2(F(D))+eps)));
    e = img_norm(y - F(D));
    E = [E; e];
end

end

