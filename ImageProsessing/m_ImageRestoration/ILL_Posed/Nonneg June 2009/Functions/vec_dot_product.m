  function c = vec_dot_product(x,y);

%  If x and y are cell arrays, compute the sum of dot products of the 
%  component vectors, i.e.,
%      c = sum_i dot_product(x{i},y{i}).
%  Otherwise, compute the usual dot the vectors x and y.

  if iscell(x)
    n_cellx = max(size(x));
    n_celly = max(size(y));
    if n_cellx ~= n_celly
 fprintf('*** Cell arrays x, y in VEC_DOT_PRODUCT.M must be the same size.\n');
      return
    end
    c = 0;
    for i = 1:n_cellx
      xi = x{i};
      yi = y{i};
      c = c + xi(:)'*yi(:);
    end

  else
    c = x(:)'*y(:);
  end
