% The function: isOrthogonal(S, epsilon)
%
% Input:
%	+ S: a matrix m x n representing a set of n vectors, each has m entries.
%	+ epsilon: a positive real number. Any number x such that -epsilon < x < epsilon will be considered as 0
%
% Output:
%	+ result = 0 if n vectors in S do not form an orthogonal set.
%	+ result = 1 otherwise.
function result = isOrthogonal(vectorSet, varargin)
	if nargin < 2
		epsilon = 1e-12;
	else
		epsilon = varargin{1};
		if epsilon < 0
			epsilon = -epsilon;
		end
	end

	sizeMat = size(vectorSet);
	numVector = sizeMat(2);
	for i = 1 : numVector
		for j = (i + 1) : numVector
			innerProduct = vectorSet(:, i)' * vectorSet(:, j);

			% Standardize the complex number
			imaginary = imag(innerProduct);
			realPart = real(innerProduct);
			if ~(-epsilon < imaginary && imaginary < epsilon && -epsilon < realPart && realPart < epsilon)
				% There exists 1 inner product that is not 0. Hence, the set is not orthgonal.
				result = 0;
				return;
			end	
		end	
	end

	result = 1;
end