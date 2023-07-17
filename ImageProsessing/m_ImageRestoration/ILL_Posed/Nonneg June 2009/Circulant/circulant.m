  function C = circulant(c)
%
%  Construct n X n circulant matrix C from vector c of length n.
%
%      |c(1)  c(n) c(n-1) ...  c(3)  c(2)|
%      |c(2)  c(1)  c(n)  ...  ...   c(3)|
%  C = |c(3)  c(2)  c(1)  ...  ...    ...|
%      | ...                   ...    ...|
%      |c(n-1)                  c(1) c(n)|
%      |c(n)  c(n-1)  ...       c(2) c(1)|

%  Make sure that c is a vector.

  if min(size(c)) > 1
    fprintf('\n *** Input c must be a vector.\n');
    return
  end

  c = c(:);  %  Make c a column vector, if it isn't already.
  n = length(c);
  row = [c(1); c(n:-1:2)];
  C = toeplitz(c,row);
  