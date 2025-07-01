function [TM, E] = pcVC(F, y, options)
% Phase corrected Van-Cittert iterations  

options.null = 0;
maxiter = getoptions(options, 'maxiter', 100);

TM = y;

E = [];
e = img_norm(y - F(TM));
E = [E; e];

for i=1:maxiter
  H = fft2(F(TM))./(fft2(TM)+eps);
  TM = TM + real(ifft2((fft2(y)./(H+eps)-fft2(TM)).*abs(H)));
  e = img_norm(y - F(TM));
  E = [E; e];
end

end

