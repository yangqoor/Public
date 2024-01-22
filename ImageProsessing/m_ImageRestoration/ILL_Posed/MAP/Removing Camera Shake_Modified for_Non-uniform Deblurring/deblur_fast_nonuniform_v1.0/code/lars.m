function [beta,beta_path] = lars(X, y, nonneg, stop, useGram, precomputeGram, trace, mode, maxactive)
% LARS  The LARS algorithm for performing LARS-LASSO.
%
% Author: Karl Skoglund, IMM, DTU, kas@imm.dtu.dk
% Reference: 'Least Angle Regression' by Bradley Efron et al, 2003.
% 
% Modified by Oliver Whyte, February 2011
%   - Added non-negative option for lasso
%   - Added option to use only precomputed values for Gram matrix X'*X and 
%           for X'*y, without requiring X or y themselves
%   - Added other modes
%   - Added separate stopping condition on number of variables
%   - Removed normal LARS  -- only use lasso variant

%% Input checking
% Set default values.
if ~exist('nonneg','var') || isempty(nonneg)
    nonneg = 0;
end
if ~exist('maxactive','var') || isempty(maxactive)
    maxactive = inf;
end
if ~exist('trace','var') || isempty(trace)
    trace = 0;
end
if ~exist('precomputeGram','var') || isempty(precomputeGram)
    precomputeGram = 0;
end
if ~exist('useGram','var') || isempty(useGram)
    useGram = 1;
end
if ~exist('stop','var') || isempty(stop)
    stop = 0;
end
if ~exist('mode','var') || isempty(mode)
    % Mode is like SPAMS
    % mode = 0: min_{alpha} ||x-Dalpha||_2^2 s.t. ||alpha||_1 <= lambda
    % mode = 1: not supported
    % mode = 2: min_{alpha} 0.5||x-Dalpha||_2^2 + lambda||alpha||_1
    mode = 0;
elseif mode==1
    error('unknown value for mode')
end

lasso = 1;

%% LARS variable setup
[n p] = size(X);
nvars = min(n-1,p); % 
maxk = 8*nvars; % Maximum number of iterations

if stop == 0
    beta = zeros(2*nvars, p);
elseif stop < 0
    beta = zeros(2*round(-stop), p);
else
    beta = zeros(100, p);
end
mu = zeros(n, 1); % current "position" as LARS travels towards lsq solution
I = 1:p; % inactive set
A = []; % active set

% Calculate Gram matrix if necessary
if useGram
    if precomputeGram
        Gram = X;
        Xt_y = y;
    else
        Gram = X'*X; % Precomputation of the Gram matrix. Fast but memory consuming.
        Xt_y = X'*y;
    end
    Xt_mu = zeros(p,1);
else
    R = []; % Cholesky factorization R'R = X'X where R is upper triangular
end

lassocond = 0; % LASSO condition boolean
stopcond = 0; % Early stopping condition boolean
k = 0; % Iteration count
vars = 0; % Current number of variables
lambda = zeros(1,p+1); % equivalent regularization weights

if trace
    disp(sprintf('Step\tAdded\tDropped\t\tActive set size'));
end

%% LARS main loop
while vars <= nvars && ~stopcond && k < maxk
    if useGram
        c = Xt_y - Xt_mu;
    else
        c = X'*(y - mu);
    end
    if isempty(I)
        C = 0;
    else
        if nonneg
            [C j] = max(c(I));
        else
            [C j] = max(abs(c(I)));
        end
    end
    % Equivalent lambdas ("On the LASSO and Its Dual", Michael R. Osborne; Brett Presnell; Berwin A. Turlach
    % Journal of Computational and Graphical Statistics, Vol. 9, No. 2. (Jun., 2000), pp. 319-337)
    % lambda(k+1) = (y-X*beta)'*X*beta/sum(abs(beta));
    % lambda(k+1) = max(abs(X'*(y-X*beta)));
    lambda(k+1) = max(C, 0);
    % Early stopping at specified regularization weight
    if mode == 2 && stop >= lambda(k+1)
        if k == 0
            warning('lambda set too high -- zero solution');
            beta(k+1,:) = 0;
            break;
        end
        t1 = lambda(k+1);
        t2 = lambda(k);
        s = (stop - t1)/(t2 - t1); % interpolation factor 0 < s < 1
        beta(k+1,:) = beta(k+1,:) + s*(beta(k,:) - beta(k+1,:));
        break;
    end

    if vars==nvars || min(abs(c))<=1e-11, break; end

    k = k + 1;

    j = I(j);

    if ~lassocond % if a variable has been dropped, do one iteration with this configuration (don't add new one right away)
        if ~useGram
            R = cholinsert(R,X(:,j),X(:,A));
        end
        A = [A j];
        I(I == j) = [];
        vars = vars + 1;
        if trace
            disp(sprintf('%d\t\t%d\t\t\t\t\t%d', k, j, vars));
        end
    end

    if nonneg
        s = ones(size(c(A))); % get the signs of the correlations
    else
        s = sign(c(A)); % get the signs of the correlations
    end

    if useGram
        S = s*ones(1,vars);
        if nonneg
            GA1 = Gram(A,A) \ ones(vars,1);
        else
            GA1 = inv(Gram(A,A).*S'.*S)*ones(vars,1);
        end
        AA = 1/sqrt(sum(GA1));
        sw = AA*GA1.*s; % weights applied to each active variable to get equiangular direction
    else
        GA1 = R\(R'\s);
        AA = 1/sqrt(sum(GA1.*s));
        sw = AA*GA1;
    end
    d = zeros(p,1);
    d(A) = sw;
    if useGram
        Xt_u = Gram(:,A)*sw; % = X' * XA * w;
    else
        u = X(:,A)*sw; % equiangular direction (unit vector)
    end

    if vars == nvars % if all variables active, go all the way to the lsq solution
        gamma = C/AA;
    else
        if useGram
            a = Xt_u;
        else
            a = X'*u; % correlation between each variable and eqiangular vector
        end
        if nonneg
            temp = (C - c(I))./(AA - a(I)); % main change for nonnegative case
        else
            temp = [(C - c(I))./(AA - a(I)); (C + c(I))./(AA + a(I))];
        end
        gamma = min([temp(temp > 0); C/AA]);
    end

    % LASSO modification
    lassocond = 0;
    temp = -beta(k,A)./d(A)';
    [gamma_tilde] = min([temp(temp > 0) gamma]);
    j = find(temp == gamma_tilde);
    if gamma_tilde < gamma,
        gamma = gamma_tilde;
        lassocond = 1;
    end

    if useGram
        Xt_mu = Xt_mu + gamma * Xt_u;
    else
        mu = mu + gamma*u;
    end
    if size(beta,1) < k+1
        beta = [beta; zeros(size(beta,1), p)];
    end
    beta(k+1,A) = beta(k,A) + gamma*d(A)';

    % Early stopping at specified bound on L1 norm of beta
    if mode == 0 && stop > 0
        t2 = sum(abs(beta(k+1,:)));
        if t2 >= stop
            t1 = sum(abs(beta(k,:)));
            s = (stop - t1)/(t2 - t1); % interpolation factor 0 < s < 1
            beta(k+1,:) = beta(k,:) + s*(beta(k+1,:) - beta(k,:));
            stopcond = 1;
        end
    end

    % If LASSO condition satisfied, drop variable from active set
    if lassocond == 1
        if ~useGram
            R = choldelete(R,j);
        end
        I = [I A(j)];
        A(j) = [];
        vars = vars - 1;
        if trace
            disp(sprintf('%d\t\t\t\t%d\t\t\t%d', k, j, vars));
        end
    end

    % Early stopping at specified number of variables
    if stop < 0
        stopcond = nnz(beta(k+1,:)) >= -stop;
    end
    if isfinite(maxactive) && maxactive>0
        stopcond = nnz(beta(k+1,:)) >= maxactive;
    end
end

% trim beta
if size(beta,1) > k+1
    beta(k+2:end, :) = [];
    lambda(k+2:end) = [];
end

beta_path = beta;
beta = beta(end,:);

if k == maxk
    disp('LARS warning: Forced exit. Maximum number of iteration reached.');
end

%% Fast Cholesky insert and remove functions
% Updates R in a Cholesky factorization R'R = X'X of a data matrix X. R is
% the current R matrix to be updated. x is a column vector representing the
% variable to be added and X is the data matrix containing the currently
% active variables (not including x).
function R = cholinsert(R, x, X)
diag_k = x'*x; % diagonal element k in X'X matrix
if isempty(R)
    R = sqrt(diag_k);
else
    col_k = x'*X; % elements of column k in X'X matrix
    R_k = R'\col_k'; % R'R_k = (X'X)_k, solve for R_k
    R_kk = sqrt(diag_k - R_k'*R_k); % norm(x'x) = norm(R'*R), find last element by exclusion
    R = [R R_k; [zeros(1,size(R,2)) R_kk]]; % update R
end

% Deletes a variable from the X'X matrix in a Cholesky factorisation R'R =
% X'X. Returns the downdated R. This function is just a stripped version of
% Matlab's qrdelete.
function R = choldelete(R,j)
R(:,j) = []; % remove column j
n = size(R,2);
for k = j:n
    p = k:k+1;
    [G,R(p,k)] = planerot(R(p,k)); % remove extra element in column
    if k < n
        R(p,k+1:n) = G*R(p,k+1:n); % adjust rest of row
    end
end
R(end,:) = []; % remove zero'ed out row

%% To do
%
% There is a modification that turns least angle regression into stagewise
% (epsilon) regression. This has not been implemented. 
