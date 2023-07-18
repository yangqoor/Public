function lambda = newton(lambda_0,delta,s,beta,omega,delta_0) 
%NEWTON Newton iteration (utility routine for DISCREP). 
% 
% lambda = newton(lambda_0,delta,s,beta,omega,delta_0) 
% 
% Uses Newton iteration to find the solution lambda to the equation 
%    || A x_lambda - b || = delta , 
% where x_lambda is the solution defined by Tikhonov regularization. 
% 
% The initial guess is lambda_0. 
% 
% The norm || A x_lambda - b || is computed via s, beta, omega and 
% delta_0.  Here, s holds either the singular values of A, if L = I, 
% or the c,s-pairs of the GSVD of (A,L), if L ~= I.  Moreover, 
% beta = U'*b and omega is either V'*x_0 or the first p elements of 
% inv(X)*x_0.  Finally, delta_0 is the incompatibility measure. 
 
% Reference: V. A. Morozov, "Methods for Solving Incorrectly Posed 
% Problems", Springer, 1984; Chapter 26. 
 
% Per Christian Hansen, IMM, 12/29/97. 
 
% Set defaults. 
thr = sqrt(eps);  % Relative stopping criterion. 
it_max = 50;      % Max number of iterations. 
 
% Initialization. 
if (lambda_0 < 0) 
  error('Initial guess lambda_0 must be nonnegative') 
end 
[p,ps] = size(s); 
if (ps==2), sigma = s(:,1); s = s(:,1)./s(:,2); end 
s2 = s.^2; 
 
% Use Newton's method to solve || b - A x ||^2 - delta^2 = 0. 
% It was found experimentally, that this formulation is superior 
% to the formulation || b - A x ||^(-2) - delta^(-2) = 0. 
lambda = lambda_0; step = 1; it = 0; 
while (abs(step) > thr*lambda & abs(step) > thr & it < it_max), it = it+1; 
  f = s2./(s2 + lambda^2); 
  if (ps==1) 
    r = (1-f).*(beta - s.*omega); 
    z = f.*r; 
  else 
    r = (1-f).*(beta - sigma.*omega); 
    z = f.*r; 
  end 
  step = (lambda/4)*(r'*r + (delta_0+delta)*(delta_0-delta))/(z'*r); 
  lambda = lambda - step; 
  % If lambda < 0 then restart with smaller initial guess. 
  if (lambda < 0), lambda = 0.5*lambda_0; lambda_0 = 0.5*lambda_0; end 
end 
 
% Terminate with an error if too many iterations. 
if (abs(step) > thr*lambda & abs(step) > thr) 
  error(['Max. number of iterations (',num2str(it_max),') reached']) 
end