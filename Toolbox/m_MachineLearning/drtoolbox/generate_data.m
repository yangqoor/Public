function [X, labels] = generate_data(dataname, n, noise)
%GENERATE_DATA Generates an artificial dataset
%
%	[X, labels] = generate_data(dataname, n, noise)
%
% Generates an artificial dataset. Possible datasets are: 'swiss' for the Swiss roll
% dataset, 'helix' for the helix dataset, 'twinpeaks' for the twinpeaks dataset,
% '3d_clusters' for the 3D clusters dataset, and 'intersect' for the intersecting
% dataset. The variable n indicates the number of datapoints to generate 
% (default = 1000). The variable noise indicates the amount of noise that
% is added to the data (default = 0.05).
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

	if ~exist('n', 'var')
		n = 1000;
    end
    if ~exist('noise', 'var')
        noise = 0.05;
    end

	switch dataname
        case 'swiss'
            t = (3 * pi / 2) * (1 + 2 * rand(1, n));  
            height = 21 * rand(1, n);
            X = [t .* cos(t); height; t .* sin(t)]' + noise * randn(n, 3);
            labels = uint8(t)';
            
        case 'changing_swiss'
            r = zeros(1, n);
            for i=1:n
                pass = 0;
                while ~pass
                    rr = rand(1);
                    if rand(1) > rr
                        r(i) = rr;
                        pass = 1;
                    end
                end
            end
            t = (3 * pi / 2) * (1 + 2 * r);  
            height = 21 * rand(1, n);
            X = [t .* cos(t); height; t .* sin(t)]' + noise * randn(n, 3);
            labels = uint8(t)';
            
        case 'helix'
        	t = [1:n]' / n;
        	t = t .^ (1.0) * 2 * pi;
			X = [(2 + cos(8 * t)) .* cos(t) (2 + cos(8 * t)) .* sin(t) sin(8 * t)] + noise * randn(n, 3);
        	labels = uint8(t);
            
        case 'twinpeaks'
            inc = 1.5 / sqrt(n);
            [xx2, yy2] = meshgrid(-1:inc:1);
            zz2 = sin(pi * xx2) .* tanh(3 * yy2);
            xy = 1 - 2 * rand(2, n);
            X = [xy; sin(pi * xy(1,:)) .* tanh(3 * xy(2,:))]' + noise * randn(n, 3);
            X(:,3) = X(:,3) * 10;
            labels = uint8(X(:,3));
            
        case '3d_clusters'
            numClusters = 5;
            centers = 10 * rand(numClusters, 3);
            D = L2_distance(centers', centers', 1);
            minDistance = min(D(find(D > 0)));
            k = 1;
            n2 = n - (numClusters - 1) * 9;
            for i=1:numClusters
                for j=1:ceil(n2 / numClusters)
                   X(k, 1:3) = centers(i, 1:3) + (rand(1, 3) - 0.5) * minDistance / sqrt(12);
                   labels(k) = i;
                   k = k + 1;
               end
               %if i < numClusters
               %    for t=0.1:0.1:0.9
               %         X(k, 1:3) = centers(i, 1:3) + (centers(i + 1, 1:3) - centers(i, 1:3)) * t;
               %         labels(k) = 0;
               %         k = k + 1;
               %     end
               %end
            end
            X = X + noise * randn(size(X, 1), 3);
            labels = labels';
            
        case 'intersect'
            t = [1:n]' ./ n .* (2 * pi);
            x = cos(t);
            y = sin(t);
            X = [x x .* y rand(length(x), 1) * 5] + noise * randn(n, 3);
            labels = uint8(5 * t);
            
        case 'intersect_2d'
            t = [1:n]' ./ n .* (2 * pi);
            x = cos(t);
            y = sin(t);
            X = [x x .* y] + noise * randn(n, 2);
            labels = uint8(5 * t);
			
		otherwise
			error('Unknown dataset name.');
	end
