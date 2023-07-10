function a_next = iterative_spca(x, a_current, output)
%ITERATIVE_SPCA Performs single SPCA iteration
%
%   a_next = iterative_spca(x, a_current, output)
%
% Performs single SPCA iteration. This function is used by the SPCA
% function.
%
%

% This file is part of the Matlab Toolbox for Dimensionality Reduction v0.3b.
% The toolbox can be obtained from http://www.cs.unimaas.nl/l.vandermaaten
% You are free to use, change, or redistribute this code in any way you
% want for non-commercial purposes. However, it is appreciated if you 
% maintain the name of the original author.
%
% (C) Laurens van der Maaten
% Maastricht University, 2007

    % Perform a single SPCA update
    s_x = size(x);
    n_features = s_x(1,1);
    y = a_current' * x;
    phi_2 = (1 / pdist([a_current'; zeros(1, n_features)])) * y * x;
    a_next = a_current + phi_2;
