% The function: computeRankRREF(matrix, epsilon)
% 
% Inputs:
%	+ matrix: an m x n matrix.
%	+ epsilon: a positive real number. Any number x such that 0 < abs(x) < epsilon will be considered as 0.
%
% Output:
%	+ rankMat: rank of the input matrix.
%
% Methodology: We compute rank based on the RREF of the input matrix.
function rankMatrix = computeRankRREF(matrix, varargin)
	if nargin < 2
		epsilon = 1e-12;
	else
		epsilon = varargin{1};
		if epsilon < 0
			epsilon = -epsilon
		end
	end

	rrefMat = toRREF(matrix, epsilon);

	sizeMat = size(matrix);
	numRow = sizeMat(1);
	numZeroRow = 0;
	for row = 1 : numRow
		if norm(rrefMat(row, :)) < epsilon
			numZeroRow = numZeroRow + 1;
		end
	end

	rankMatrix = numRow - numZeroRow;
end