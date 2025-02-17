function [x, k, Rnrm, Xnrm, Enrm] = ...
                      MRNSD(A, b, x, MaxIts, tol, x_exact, noise_info)
%
% [x, k, Rnrm, Xnrm, Enrm] = MRNSD(A, b, x, MaxIts, tol, x_exact, noise_info);
%
%  Modified Residual Norm Steepest Descent for weighted least squares
%
%  Nonnegatively constrained steepest descent method.
%
%  References:
%   [1]  J. Nagy, Z. Strakos.
%        "Enforcing nonnegativity in image reconstruction algorithms"
%         in Mathematical Modeling, Estimation, and Imaging, 
%         David C. Wilson, et.al., Eds., 4121 (2000), pg. 182--190. 
%   [2]  L. Kaufman.
%        "Maximum likelihood, least squares and penalized least squares
%         for PET",
%         IEEE Trans. Med. Imag. 12 (1993) pp. 200--214.
%
%   Input: A  -  object defining the coefficient matrix.
%          b  -  Right hand side vector
%          x  -  initial guess 
% 
%   Optional Intputs:
%     MaxIts  -  number of iterations to perform (default = length(b(:)))
%        tol  -  tolerance for stopping (default = sqrt(eps)*norm(b))
%    x_exact  -  if the exact solution is known, we can compute relative
%                errors at each iteration
% 
%   Output:
%          x  -  solution
%          k  -  actual number of iterations performed
%       Rnrm  -  norm of the residual at each iteration
%       Xnrm  -  norm of the solution at each iteration
%       Enrm  -  norm of the true error at each iteration (if x_exact is known)
%

% J. Nagy, 02-13-01

%
% check for inputs, and set default values (default tol will be
% set later)
%

disp(' '), disp('Beginning MRNSD iterations')
disp(' '), disp('Iteration number ...') 

tau = sqrt(eps);
sigsq = tau;
minx = min(min(x));

%
%  if initial guess has negative values, compensate
%
if minx < 0
     x = x - min(0,minx) + sigsq;
end


n = length(b(:));
if nargin < 4
  MaxIts = n;, tol = [];, x_exact = [];
elseif nargin < 5
  tol = [];, x_exact = [];
elseif nargin < 6
  x_exact = [];
end
if isempty(x), x = zeros(size(b));, end
if isempty(MaxIts), MaxIts = n;, end

%
%  Initialize some values before iterations begin.
%
Rnrm = zeros(MaxIts, 1);
Xnrm = zeros(MaxIts, 1);

trAb = A'*b;

nrm_trAb = norm(trAb(:));

if isempty(tol) 
  tol = sqrt(eps)*nrm_trAb;
end

if ~isempty(x_exact)
  Enrm = zeros(MaxIts, 1);
  nrm_x_exact = norm(x_exact(:));
  x_error = x - x_exact;
  Enrm(1) = norm(x_error(:)) / nrm_x_exact;
end

% Determine weight matrix  
sigma_sq = get_sigma_sq(noise_info); %A*x_exact + stdev;
Wt = sqrt(1./sigma_sq);

r = A*x;
r = b - r;
Wt_r = (Wt.^2).*r;
g = A'*Wt_r;
g = -g;

xg = x .* g;
gamma = g(:)' * xg(:);

Rnrm(1) = norm(sqrt(gamma));
Xnrm(1) = norm(x(:));

k = 0;
while ( Rnrm(k+1) > tol & k <= MaxIts-1 )
  k = k + 1;
  fprintf('%5.0f',k)

  s = - x .* g;

  u = A*s;
  u = Wt.*u;

  theta = gamma / (u(:)'*u(:));
  neg_ind = s < 0;

  alpha = min( theta, min( -x(neg_ind) ./ s(neg_ind) ) );
  if isempty(alpha)
    alpha = theta;
  end

  x = x + alpha*s;

  u = Wt.*u;
  z = A'*u;

  g = g + alpha*z;
  xg = x .* g;
  gamma = g(:)' * xg(:);

  if ~isempty(x_exact)
    x_error = x - x_exact;
    Enrm(k+1) = norm(x_error(:)) / nrm_x_exact;
  end

  Rnrm(k+1) = norm(sqrt(gamma));
  Xnrm(k+1) = norm(x(:));

  end
Rnrm = Rnrm(1:k+1)/nrm_trAb;
Xnrm = Xnrm(1:k+1);
if ~isempty(x_exact)
  Enrm = Enrm(1:k+1);
else
  Enrm = [];
end
