function [hx,X] = Hconv(h,x,L,ceilL)

%%% compute h*x where length(h) < length(x)
%%% output: signal same length of x 

x = [x(ceilL:end);x(1:ceilL-1)];
%if length(x)>=L
X = toeplitz(x,[x(1),x(end:-1:end-L+2)']);
% else 
%     X = toeplitz(x,[x(1),zeros(1,L-1)]);
% end

hx = X*h;


