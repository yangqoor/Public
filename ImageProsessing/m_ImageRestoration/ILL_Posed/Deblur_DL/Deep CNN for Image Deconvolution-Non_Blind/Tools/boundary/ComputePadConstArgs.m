function ConstArgs = ComputePadConstArgs(imH, imW, psf)

fx = [0 -1 1]; fy = fx';
fxx = [0 0 1 -2 1]; fyy = fxx';
fxy = [0 0 0; 0 1 -1; 0 -1 1];
wt0 = 1; wt1 = wt0*1/2; wt2 = wt0*1/4;
Gx=psf2otf(fx(end:-1:1,end:-1:1),[imH, imW]);
Gy=psf2otf(fy(end:-1:1,end:-1:1),[imH, imW]);

ConstArgs.FreqConjGx = conj(Gx);
ConstArgs.FreqConjGy = conj(Gy);
ConstArgs.FreqDerrs = conj(Gx).*Gx+conj(Gy).*Gy;

Gxx = psf2otf(fxx(end:-1:1,end:-1:1),[imH, imW]);
Gyy = psf2otf(fyy(end:-1:1,end:-1:1),[imH, imW]);
Gxy = psf2otf(fxy(end:-1:1,end:-1:1),[imH, imW]);

ConstArgs.FreqWt = ones(imH, imW);
ConstArgs.FreqWt = wt0.*ConstArgs.FreqWt+wt1.*(ConstArgs.FreqDerrs)+wt2.*(abs(Gxx).^2+abs(Gyy).^2+abs(Gxy).^2);


F =psf2otf(psf,[imH,imW]);
ConstArgs.FreqF = F;
ConstArgs.FreqConjF = conj(F);
ConstArgs.FreqF2 = abs(F).^2;

return
