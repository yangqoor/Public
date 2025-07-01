function [W, E] = mWiener(F, y, options)
% modified Wiener iterations 

% default value for 'a' from the image noise variance 
if (size(y,3) ~= 1)
    ybw = rgb2gray(y);
    nsr = estimate_noise(ybw)^2 / var(ybw(:));
else
    nsr = estimate_noise(y)^2 / var(y(:));
end
a_def = nsr;

options.null = 0;
maxiter = getoptions(options, 'maxiter', 100);
a = getoptions(options, 'a', a_def);


W = y;
FW = F(W);
H = fft2(FW)./(fft2(W)+eps);

E = [];
e = img_norm(y - FW);
E = [E; e];

for i=1:maxiter
    H = H*(i-1)/i + fft2(FW)./(fft2(W)+eps)/i;
    Hconj = conj(H);
    W = real(ifft2((Hconj./(Hconj.*H+a)).*fft2(y)));
    FW = F(W);
    e = img_norm(y - FW);
    E = [E; e];
end

end
