function xadjy = Xconv_adj(x,y,L,ceilL)

%%%% compute the convolution adjoint of Xconv1,
%%%%where length(x) = length(y)>L
%%%% output: signal of length L


x = [x(ceilL:end);x(1:ceilL-1)];

%if length(x)>=L
    X = toeplitz(x,[x(1),x(end:-1:end-L+2)']);
%else 
%     X = toeplitz(x,[x(1),zeros(1,L-1)]);
% end

xadjy = X'*y;
