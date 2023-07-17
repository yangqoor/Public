function [x, Rnrm, Xnrm, Enrm, fftvec] = MRNSD(x,opt_params,cost_params)
%
%  Modified Residual Norm Steepest Descent
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

%  J. Nagy, 02-13-01

%
%  check for inputs, and set default values (default tol will be
%  set later)
%

global TOTAL_FFTS TOTAL_FFT_TIME

%  Extract necessary parameters.

nx      = cost_params.nx;
ny      = cost_params.ny;
b       = cost_params.data;
t_hat   = cost_params.blurring_operator;
MaxIts  = opt_params.max_iter;
tol     = opt_params.tol;
x_exact = opt_params.f_true;

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

%
%  Initialize some values before iterations begin.
%
Rnrm   = zeros(MaxIts, 1);
Xnrm   = zeros(MaxIts, 1);
fftvec = zeros(MaxIts, 1);

trAb = real(ifft2(conj(t_hat).*fft2(b)));  %A'*b;
TOTAL_FFTS = TOTAL_FFTS + 2;

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


r = real(ifft2(t_hat.*fft2(x))); %A*x;
r = b - r;
g = real(ifft2(conj(t_hat).*fft2(r))); %A'*r;
g = -g;

TOTAL_FFTS = TOTAL_FFTS + 4;

xg = x .* g;
gamma = g(:)' * xg(:);

Rnrm(1) = norm(sqrt(gamma));
Xnrm(1) = norm(x(:));
fftvec(1) = TOTAL_FFTS;

k = 0;
while ( Rnrm(k+1) > tol & k <= MaxIts-1 )
  k = k + 1;
  fprintf('%5.0f',k)

  s = - x .* g;

  u = real(ifft2(t_hat.*fft2(s))); %A*s;
  TOTAL_FFTS = TOTAL_FFTS + 2;
  
  theta = gamma / (u(:)'*u(:));
  neg_ind = s < 0;

  alpha = min( theta, min( -x(neg_ind) ./ s(neg_ind) ) );
  if isempty(alpha)
    alpha = theta;
  end

  x = x + alpha*s;

  z = real(ifft2(conj(t_hat).*fft2(x))); %A'*u;
  TOTAL_FFTS = TOTAL_FFTS + 2;

  g = g + alpha*z;
  xg = x .* g;
  gamma = g(:)' * xg(:);

  if ~isempty(x_exact)
    x_error = x - x_exact;
    Enrm(k+1) = norm(x_error(:)) / nrm_x_exact;
  end

  Rnrm(k+1) = norm(sqrt(gamma));
  Xnrm(k+1) = norm(x(:));
  fftvec(k+1) = TOTAL_FFTS;  

  figure(1)
    imagesc(x)

  figure(2)
   subplot(221)
     plot(Enrm)
     title('Enrm')
   subplot(222)
     plot(Rnrm)
     title('Rnrm')
   subplot(223)
     plot(Xnrm)
     title('Xnrm')
end

Rnrm = Rnrm(1:k+1)/nrm_trAb;
Xnrm = Xnrm(1:k+1);
if ~isempty(x_exact)
  Enrm = Enrm(1:k+1);
else
  Enrm = [];
end
