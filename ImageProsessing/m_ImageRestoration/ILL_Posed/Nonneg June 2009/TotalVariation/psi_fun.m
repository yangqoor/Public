  function s = psi(t,beta)
  
  s = 2*sqrt(t + beta^2);

%  What follows corresponds to 
%      psi(t) = t / beta,         if t <= beta^2,
%      psi(t) = 2*sqrt(t) - beta, if t > beta^2.
%  This psi is C^1, with a discontinuous second derivative. This will not
%  work with methods which require continuous second order derivatives.

  indx = (t > beta^2);
  s = (1-indx) .* t / beta + indx .* (2*sqrt(t+eps) - beta);
