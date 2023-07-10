% The function: isOrthoBasis(vectorSet, basis, epsilon)
%
% Inputs:
%	+ vectorSet: a m x n matrix representing a set of n column vectors, each has m entries.
%	+ basis: a matrix representing a supposed orthonormal basis of vectorSet.
%	+ epsilon: a positive real number. Any number x such that 0 < abs(x) < epsilon will be considered as 0.
%
% Output:
%	+ result = 1 if basis is truly the orthonormal basis of vectorSet.
%	+ result = 0 otherwise.
%
% Assumption:
%	+ The number of rows in vectorSet should be the same as that of basis
function result = isOrthoBasis(vectorSet, basis, varargin)
	if nargin < 3
		epsilon = 1e-12;
	else
		epsilon = varargin{1};
		if epsilon < 0
			epsilon = -epsilon;
		end
	end

	if isOrthonormal(basis, epsilon)
		if spanSameSpace(vectorSet, basis, epsilon)
			result = 1;
		else
			result = 0;
	else
		result = 0;
	end
end