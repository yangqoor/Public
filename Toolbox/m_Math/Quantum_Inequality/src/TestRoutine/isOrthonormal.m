% The function: isOrthonormal(S)
%
% Input:
%	+ S: a matrix m x n representing a set of n vectors, each has m entries.
%	+ epsilon: a positive real number. Any number x such that -epsilon < x < epsilon will be considered as 0
%
% Output:
%	+ result = 0 if n vectors in S do not form an orthonormal set.
%	+ result = 1 otherwise.
%
% Methodology:
%	+ First, check if the set S is orthogonal.
%	+ Then, check if vectors in S are unit vectors.
function result = isOrthonormal(vectorSet, varargin)
	if nargin < 2
		epsilon = 1e-12;
	else
		epsilon = varargin{1};
		if epsilon < 0
			epsilon = -epsilon;
		end
	end

	if ~isOrthogonal(vectorSet, epsilon)
		result = 0;
	else
		% Check if vectors in the input set are unit vectors
		sizeMat = size(vectorSet);
		numVector = sizeMat(2);

		for index = 1 : numVector
			vectorNorm = vectorSet(:, index)' * vectorSet(:, index);

			if ~((-epsilon + 1) < vectorNorm and vectorNorm < (1 + epsilon))
				result = 0;
				return;
			end 
		end
	end

	result = 1;
end