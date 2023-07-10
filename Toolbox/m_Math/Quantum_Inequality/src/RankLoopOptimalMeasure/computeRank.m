% The function: computeRank(M, epsilon)
%
% Input:
%	+ M: an m x n matrix.
%	+ epsilon: a threshold value. The number N satisfying -epsilon < N < epsilon will be considered as 0.
%
% Output:
%	+ rankMatrix: the rank of the input matrix.
%
% Methodology: 
%	+ We know that the rank of a matrix is equal to the number of its nonzero singular values.
function rankMatrix = computeRank(M, epsilon)
	if epsilon < 0
		epsilon = -epsilon;
	end
	
	[rangeMat singularMat ~] = svd(M);

	singularVal = diag(singularMat);

	rankMatrix = sum(~(singularVal < epsilon & singularVal > -epsilon));
end