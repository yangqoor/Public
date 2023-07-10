function [x0,h0,epsx,hmin,hmax,epsh] = initialization(xtrue,htrue)

L = length(htrue); 
sigma = 2 ; c = floor(L/2)+1 ; gg = 1:L ;
gauss_c = exp(-(gg - c).^2/(2*sigma^2));
h0 = (gauss_c .* max(htrue))' ;
h0 = h0 - mean(h0) ;                   % sum(h0) = 0
h0 = projection_l2(h0,norm(htrue)) ;

epsx0 = max(abs(xtrue)) ;
x0 = max(xtrue)*ones(size(xtrue)) ;
x0 = projection_l2(x0,epsx0) ;


epsx = [min(xtrue) max(xtrue)] ;

hmin = min(htrue) ;
hmax = max(htrue) ;
epsh = norm(htrue);
end
