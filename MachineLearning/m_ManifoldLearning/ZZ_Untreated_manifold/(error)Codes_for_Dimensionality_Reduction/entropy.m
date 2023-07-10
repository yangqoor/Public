function e = entropy(x, y)
%ENTROPY Computes entropy e for vector x or joint entropy for (x, y).
%
%   e = entropy(x)
%   e = entropy(x, y)
%
% Computes entropy e for vector x or joint entropy for (x, y). This
% function uses base number 1024 for the logarithm.
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


    warning off
    
    % Compute relative frequency of values
    x = x(1:end);
    if nargin == 1        
        p = freq(double(x));
    else
        if numel(x) ~= numel(y)
            e = -1;
            warning('Sizes of vector do not match.');
            return;
        end
        y = y(1:end);
        p = joint_freq(double(x), double(y));
    end

    % Compute Shannon entropy
    xlogy(repmat(256, [length(p) 1]), p);
    e = -sum(p .* xlogy(repmat(256, [length(p) 1]), p));