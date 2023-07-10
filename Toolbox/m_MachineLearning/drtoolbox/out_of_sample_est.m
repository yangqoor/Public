function t_points = out_of_sample_est(points, X, mappedX)
%TRANSFORM_SAMPLE_EST Performs out-of-sample extension using estimation technique
%
%   t_points = out_of_sample_est(points, X, mappedX)
%
% Performs out-of-sample extension using estimation technique on datapoints
% points. You also need to specify the original dataset in X, and the
% reduced dataset in mappedX (the two datasets may also be PRTools datasets).
% The function returns the coordinates of the transformed points in t_points.
%
%

% This file is part of the Matlab Toolbox for Dimensionality Reduction v0.2b.
% The toolbox can be obtained from http://www.cs.unimaas.nl/l.vandermaaten
% You are free to use, change, or redistribute this code in any way you
% want. However, it is appreciated if you maintain the name of the original
% author.
%
% (C) Laurens van der Maaten
% Maastricht University, 2007


    % Handle PRTools dataset
    if strcmp(class(points), 'dataset')
        prtools = 1;
        ppoints = points;
        points = points.data;
    else 
        prtools = 0;
    end

    % Handle PRTools datasets
    if strcmp(class(X), 'dataset')
        X = X.data;
    end
    if strcmp(class(mappedX), 'dataset')
        mappedX = mappedX.data;
    end

    % For all datapoints
    t_points = repmat(0, [size(points, 1) size(mappedX, 2)]);
    for i=1:size(points, 1)
        
        % Get current point
        point = points(i,:);
        
        % Find nearest neighbor for point
        n = size(X, 1);
        D = zeros(1, n);
        aa = sum(point .* point);
        bb = sum(X' .* X');
        ab = point * X';
        d = sqrt(repmat(aa', [1 size(bb, 2)]) + repmat(bb, [size(aa, 2) 1]) - 2 * ab);
        [d, ind] = min(d);

        % Compute transformation matrix
        L = pinv(X(ind,:) - mean(X(ind,:))) * (mappedX(ind,:) - mean(mappedX(ind,:)));

        % Compute coordinates of transformed point
        t_points(i,:) = (mean(mappedX(ind,:)) + ((point - mean(X(ind,:))) * L))';
    end
    
    % Handle PRTools dataset
    if prtools == 1
        ppoints.data = t_points;
        t_points = ppoints;
    end
    