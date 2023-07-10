% The function: checkMomentDecompose(matrix, vectorSet, epsilon)
%
% Inputs:
%	+ matrix: an n x n matrix
%	+ vectorSet: a matrix whose columns represent the set of n vectors.
%
% Outputs:
%	+ result = 1 if for all 1 <= i, j <= n, we have matrix(i, j) = vectorSet(:, i)' * vectorSet(:, j)
%	+ result = 0 otherwise
%	+ epsilon: (In case result = 1) a positive real number. Any number x such that -epsilon < x < epsilon will be considered as 0. It is 
%				the tolerance for which result = 1
function [result epsilon] = checkMomentDecompose(matrix, vectorSet)
	epsilon = 1e-12;

	sizeMat = size(matrix);
	order = sizeMat(1);		% Assume matrix is a square matrix!

	while epsilon < 1e-5
		result = 1;
		for i = 1 : order
			for j = 1 : order
				innerProduct = vectorSet(:, i)' * vectorSet(:, j);

				gap = matrix(i, j) - innerProduct;

				if ~(abs(gap) < epsilon)
					result = 0;
					break;
				end
			end

			if ~result
				break;
			end
		end

		if result
			return;
		end

		epsilon = epsilon * 10;
	end

	% If the function reaches this point, result = 0
	result = 0;
end