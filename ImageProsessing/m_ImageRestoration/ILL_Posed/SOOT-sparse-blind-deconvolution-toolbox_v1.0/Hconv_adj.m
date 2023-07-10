function hadjy = Hconv_adj(h,y,L,ceilL)

%%%% compute the convolution adjoint of Hconv1,
%%%%where length(y) >L
%%%% output: signal of length(y)

y =  flipdim(y,1);
y = [y(ceilL:end);y(1:ceilL-1)];

%if length(y)>=L 
    Y = flipdim(toeplitz(y,[y(1),y(end:-1:end-L+2)']),1);
% else
%     Y = toeplitz(y,[y(1),zeros(1,L-1)]);
% end
hadjy = Y*h;

