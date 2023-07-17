  function T = my_toeplitz(t)
%
%  Construct n X n Toeplitz matrix T from vector t of length 2n-1.
%
%      | t(n)   t(n-1) t(n-2) ...  t(2)  t(1) |
%      | t(n+1) t(n)   t(n-1) ...  ...   t(2) |
%  T = | t(n+2) t(n+1) t(n)   ...  ...    ... |
%      |  ...                      ...    ... |
%      | t(2n-2)  ...         ...  t(n) t(n-1)|
%      | t(2n-1) t(2n-2) ...  ...  t(n+1) t(n)|

  m = max(length(t));
  if mod(m,2) == 0
    fprintf('\n *** Length of t must be odd.\n');
    return
  end
  
  n = ceil(m/2);
  row = t(n:-1:1);
  col = t(n:m);
  T = toeplitz(col,row);
  