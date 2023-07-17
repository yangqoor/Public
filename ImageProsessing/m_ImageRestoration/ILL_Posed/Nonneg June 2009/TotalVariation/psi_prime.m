  function s = psi_prime(t,beta)
  
  s = 1 ./ sqrt(t + beta^2);

%  What follows corresponds to 
%      psi(t) = t / beta,         if t <= beta^2,
%      psi(t) = 2*sqrt(t) - beta, if t > beta^2.
%  This works if psi is C^1, with a discontinuous second derivative. It 
%  will not work with methods which require continuous second order 
%  derivatives. 
%  Note that the "+eps" prevents division by zero.

%  indx = (t > beta^2);
%  s = (1-indx) / beta + indx ./ sqrt(t+eps);
  
