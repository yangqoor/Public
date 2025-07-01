function [lm, E] = mLM(F, y, options)
% Levenberg-Marquardt iterations

% default value for 'a' from the image noise variance 
if (size(y,3) ~= 1)
    ybw = rgb2gray(y);
    nsr = estimate_noise(ybw)^2 / var(ybw(:));
else
    nsr = estimate_noise(y)^2 / var(y(:));
end
a_def = 100.0 * nsr;

options.null = 0;
maxiter = getoptions(options, 'maxiter', 100);
a = getoptions(options, 'a', a_def);

lm = y;

E = [];
e = img_norm(y - F(lm));
E = [E; e];

for i=1:maxiter
    Flm = F(lm);
    H = fft2(Flm)./(fft2(lm)+1e-7);
    Hconj = conj(H);
    num = Hconj.*(fft2(y-Flm));
    denom = (Hconj.*H+a);
    lm = lm + real(ifft2(num./denom));
    e = img_norm(y - F(lm));
    E = [E; e];
end

end
