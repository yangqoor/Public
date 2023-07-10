% The function: isZeroMatrix(matrix, epsilon)
%
% Inputs:
%	+ matrix: an m x n matrix.
% 	+ epsilon: a positive real number. Any number x such that -epsilon < x < epsilon will be considered as 0
%
% Output:
%	+ result = 1 if matrix is a zero matrix with respect to epsilon.
%	+ result = 0 otherwise
function result = isZeroMatrix(matrix, varargin)
	if nargin < 2
		epsilon = 1e-12;
	else
		epsilon = varargin{1};
		if epsilon < 0
			epsilon = -epsilon;
		end
	end

	standardMat = standardizeMatrix(matrix, epsilon);
	nonZeroIndex = find(standardMat);
	if isempty(nonZeroIndex)
		result = 1;
	else
		result = 0;
	end
end