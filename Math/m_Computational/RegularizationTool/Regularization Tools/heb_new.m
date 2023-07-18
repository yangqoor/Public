function lambda = heb_new(lambda_0,alpha,s,beta,omega) 
%HEB_NEW Newton iteration with Hebden model (utility routine for LSQI). 
% 
% lambda = heb_new(lambda_0,alpha,s,beta,omega) 
% 
% Uses Newton iteration with a Hebden (rational) model to find the 
% solution lambda to the secular equation 
%    || L (x_lambda - x_0) || = alpha , 
% where x_lambda is the solution defined by Tikhonov regularization. 
% 
% The initial guess is lambda_0. 
% 
% The norm || L (x_lambda - x_0) || is computed via s, beta and omega. 
% Here, s holds either the singular values of A, if L = I, or the 
% c,s-pairs of the GSVD of (A,L), if L ~= I.  Moreover, beta = U'*b 
% and omega is either V'*x_0 or the first p elements of inv(X)*x_0. 
 
% Reference: T. F. Chan, J. Olkin & D. W. Cooley, "Solving quadratically 
% constrained least squares using block box unconstrained solvers", 
% BIT 32 (1992), 481-495. 
% Extension to the case x_0 ~= 0 by Per Chr. Hansen, IMM, 11/20/91. 
 
% Per Christian Hansen, IMM, 12/29/97. 
 
% Set defaults. 
thr = sqrt(eps);  % Relative stopping criterion.
it_max = 1150;      % Max number of iterations. 
 
% Initialization. 
if (lambda_0 < 0) 
  error('Initial guess lambda_0 must be nonnegative') 
end 
[p,ps] = size(s); 
if (ps==2), mu = s(:,2); s = s(:,1)./s(:,2); end 
s2 = s.^2; 
 
% Iterate, using Hebden-Newton iteration, i.e., solve the nonlinear 
% problem || L x ||^(-2) - alpha^(-2) = 0.  This version was found 
% experimentally to work slightæy better than Newton's method for 
% alpha-values near || L x^exact ||. 
lambda = lambda_0; step = 1; it = 0; 
while (abs(step) > thr*lambda & it < it_max), it = it+1; 
  e = s./(s2 + lambda^2); f = s.*e; 
  if (ps==1) 
    Lx = e.*beta - f.*omega; 
  else 
    Lx = e.*beta - f.*mu.*omega; 
  end 
  norm_Lx = norm(Lx); 
  Lv = lambda^2*Lx./(s2 + lambda^2); 
  step = (lambda/4)*(norm_Lx^2 - alpha^2)/(Lv'*Lx); % Newton step. 
  step = (norm_Lx^2/alpha^2)*step; % Hebden step. 
  lambda = lambda + step; 
  if (lambda < 0), lambda = 2*lambda_0; lambda_0 = 2*lambda_0; end 
end 
 
% Terminate with an error if too many iterations. 
if (abs(step) > thr*lambda), error('Max. number of iterations reached'), end