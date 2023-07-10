function out = psnr(x,y)
out = -10*log10( mean( (x(:)-y(:)).^2 ) );