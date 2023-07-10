function [mappedX, mapping] = spca(X, no_dims)
%SPCA Compute PCA mapping on X using Simple PCA
%
%   [mappedX, mapping] = spca(X, no_dims)
%
% Compute PCA mapping on X using Simple PCA. The function reduces the
% dimensionality of dataset X to no_dims. The fuctions returnd both the
% reduced dataset in mappedX and the linear PCA mapping.
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

    disp('Computing eigenvectors of covariance matrix...');
    mapping = zeros(length(X(1,:)), no_dims);
    for e=1:no_dims
        fprintf('.');
        % Intialize eigenvector
        ev = repmat(1, [size(X, 2) 1]) * 0.01;

        % Compute mean feature vector
        s = repmat(0, [1 size(X, 2)]);
        for j=1:size(X, 1)
            s = s + X(j,:);
        end
        meanFV = s / size(X, 1);

        for j=1:size(X, 1)
            % Substract mean feature vector from features
            featureVector = X(j,:) - meanFV;
            featureVector = featureVector';

            % Deflate sample with already known eigenvectors
            for ei=1:(e - 1)
                if size(featureVector) == size(mapping(:,ei))
                    featureVector = featureVector - (mapping(:,ei)' * featureVector) .* mapping(:,ei);
                end
            end

            % Perform iterative SPCA step
            if size(featureVector) == size(ev)
                ev = iterative_SPCA(featureVector, ev);
            end
        end

        % Compute final eigenvector
        ev = ev / sqrt(ev' * ev);
        mapping(:,e) = ev;
    end
    
     % Apply mapping
     for i=1:size(X, 1)
        mappedX(i,:) = X(i,:) * mapping;
     end
     disp(' ');

