function [W, e] = lms(u, d, mu, decay, verbose)

% function [W, e] = lms(u, d, mu, decay, verbose)
% Input parameters:
%       u       : matrix of training/test points - each row is
%                 considered a datum
%       d       : matrix of desired outputs - each row is
%                 considered a datum
%       mu      : step size for update of weight vectors
%       decay   : set to 1 for O(1/n) decay in m
%       verbose : set to 1 for interactive processing

% length of maximum number of timesteps that can be predicted
N    = min(size(u, 1), size(d, 1));

Nin  = size(u, 2);
Nout = size(d, 2);

% initialize weight matrix and associated parameters for LMS predictor
w = zeros(Nout, Nin);
W = [];

for n = 1:N,

W = [W ; w];

% predict next sample and error
xp(n, :) = u(n, :) * w';
e(n, :)  = d(n, :) - xp(n, :);
ne(n)    = norm(e(n, :));
if (verbose ~= 0)
    disp(['time step ', int2str(n), ': mag. pred. err. = ' , num2str(ne(n))]);
end;
% adapt weight matrix and step size
w = w + mu * e(n, :)' * u(n, :);
if (decay == 1)
  mu = mu * n/(n+1); % use O(1/n) decay rate
end;
end % for n


