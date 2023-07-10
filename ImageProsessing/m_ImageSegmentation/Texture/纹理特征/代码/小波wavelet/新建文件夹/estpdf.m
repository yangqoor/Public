function [alpha, beta, K] = estpdf(m1, m2)
% ESTPDF Estimate generalized Gaussian p.d.f of a wavelet subband
%
% Input:
%	m1: average absolute values of subband coefficients
%	m2: variances of subband coefficients
%
% Output:
%	alpha, beta, K: paramaters of generalized Gaussian p.d.f.
%	f(x) = K * exp(-(abs(x) / alpha)^beta)
%
% See also: SBPDF
%
% Note:	This is a faster version that computes beta using interpolation
%	where SBPDF use FZERO to solve inverse function

% beta = F^(-1)(m1^2 / m2);
% alpha = m1 * gamma(1/beta) / gamma(2/beta);
% K = beta / (2 * alpha * gamma(1/beta);

x = 0.05 * [1:100]';
f = [2.4663e-05 0.004612 0.026349 0.062937 0.10606 0.15013 0.19234 0.23155 ...
     0.26742 0.3 0.32951 0.35624 0.38047 0.40247 0.42251 0.44079 0.45753 ...
     0.47287 0.48699 0.5 0.51202 0.52316 0.53349 0.5431 0.55206 0.56042 ...
     0.56823 0.57556 0.58243 0.58888 0.59495 0.60068 0.60607 0.61118 ...
     0.616 0.62057 0.6249 0.62901 0.63291 0.63662 0.64015 0.64352 ...
     0.64672 0.64978 0.65271 0.6555 0.65817 0.66073 0.66317 0.66552 ...
     0.66777 0.66993 0.672 0.674 0.67591 0.67775 0.67953 0.68123 0.68288 ...
     0.68446 0.68599 0.68747 0.68889 0.69026 0.69159 0.69287 0.69412 ...
     0.69532 0.69648 0.6976 0.69869 0.69974 0.70076 0.70175 0.70271 ...
     0.70365 0.70455 0.70543 0.70628 0.70711 0.70791 0.70869 0.70945 ...
     0.71019 0.71091 0.71161 0.71229 0.71295 0.71359 0.71422 0.71483 ...
     0.71543 0.71601 0.71657 0.71712 0.71766 0.71819 0.7187 0.7192 0.71968];

val = m1^2 / m2;
if val < f(1)
    beta = 0.05;
elseif val > f(end)
    beta = 5;
else
    beta = interp1q(f, x, val);
end

alpha = m1 * exp(gammaln(1/beta) - gammaln(2/beta));

if nargout > 2
    K = beta / (2 * alpha * gamma(1/beta));
end