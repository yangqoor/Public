function hx = Xconv(h,x,N,L,ceilL)

%%% compute h*x where length(h) < length(x)
%%% output: signal same length of x 

h = [h(ceilL:end);zeros(N-L,1);h(1:ceilL-1)];
%if N >=L
H = toeplitz(h,[h(1),h(end:-1:2)']);
% else 
%      H = toeplitz(x,[x(1),zeros(1,N-1)]);
%end

hx = H*x;
