function t_point = out_of_sample(point, mapping)
%TRANSFORM_SAMPLE_EST Performs out-of-sample extension of new datapoints
%
%   t_points = out_of_sample(points, X, mappedX)
%
% Performs out-of-sample extension of the new datapoints in points. The 
% information necessary for the out-of-sample extension is contained in 
% mapping (this struct can be obtained from COMPUTE_MAPPING).
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
    if strcmp(class(point), 'dataset')
        prtools = 1;
        ppoint = point;
        point = point.data;
    else 
        prtools = 0;
    end

    switch mapping.name
        
        % Linear mappings
        case {'PCA', 'LDA', 'LPP', 'NPE', 'LLTSA', 'SPCA'}
            t_point = (point - repmat(mapping.mean, [size(point, 1) 1])) * mapping.M;
            
        % Kernel PCA mapping
        case 'KernelPCA'
            % Compute and center kernel matrix
            K = gram(mapping.X, point, mapping.kernel, mapping.param1, mapping.param2);
            J = repmat(mapping.column_sums', [1 size(K, 2)]);
            K = K - repmat(sum(K, 1), [size(K, 1) 1]) - J + repmat(mapping.total_sum, [size(K, 1) size(K, 2)]);
            
            % Compute transformed points
            t_point = mapping.invsqrtL * mapping.V' * K;
            t_point = t_point';            
                  
        % Neural network mapping (with biases)
        case {'AutoEncoder', 'AutoEncoderEA'}
            % Make zero-mean, unit variance
            point = point -  repmat(mapping.mean, [size(point, 1) 1]);
            point = point ./ repmat(mapping.var,  [size(point, 1) 1]);
            
            % Run through autoencoder
            point   = [point                                      ones(size(point, 1), 1)]; 
            w1probs = [1 ./ (1 + exp(-point   * mapping.w1))      ones(size(point, 1), 1)];
            w2probs = [1 ./ (1 + exp(-w1probs * mapping.w2))      ones(size(point, 1), 1)];
            w3probs = [1 ./ (1 + exp(-w2probs * mapping.w3))      ones(size(point, 1), 1)];
            t_point = w3probs * mapping.w4;
                        
        otherwise
            error(['A proper out-of-sample extension for ' mapping.name ' is not available in the toolbox. You might consider using OUT_OF_SAMPLE_EST instead.']);
    end
    
    % Handle PRTools dataset
    if prtools == 1
        ppoint.data = t_point;
        t_point = ppoint;
    end