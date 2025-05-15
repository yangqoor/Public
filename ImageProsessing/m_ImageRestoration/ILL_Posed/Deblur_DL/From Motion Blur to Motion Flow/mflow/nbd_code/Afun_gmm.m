%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = Afun_gmm(x,bmag, bori,counts,beta,lambda,transp_flag)
ss = size(bmag);
xx = reshape(x,ss);
Kx = motionBlurConv(xx, bmag, bori);
Kxx = motionBlurConv_mirror(Kx, bmag, bori);

y = lambda * Kxx + beta*counts.*xx;
y = y(:);

