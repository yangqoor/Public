function normHtH = normHtHconv(h,N,L,ceilL)

%%% compute the norm of HtH where
%%% H = @(h) Hconv1(h,x,L,ceilL)

h = [h(ceilL:end);zeros(N-L,1);h(1:ceilL-1)];
normHtH = toeplitz(h,[h(1),h(end:-1:2)']);
%normHtH = normHtH'*normHtH;
normHtH = norm(normHtH'*normHtH);