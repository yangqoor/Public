% The function: getOrthoBasis(M, epsilon)
% 
% Input:
%	+ M: a m x n matrix. It can be viewed of as a set of n column vectors (v1, v2, ..., vn). Each v(i) has m components.
%	+ epsilon: a extremely small real-valued number. It should be positive. Those numbers that are in the interval (-epsilon, epsilon) will be considered
%					as 0.
%
% Output:
%	+ OB: an orthonormal basis that spans the column space of M.
%
% Methodology:
%	+ Find the singular value decomposition of M, i.e. find a matrix U, D, V such that 
%		- U and V are unitary.
%		- D is a rectangular diagonal matrix with nonnegative real numbers on the diagonal.
%		- M = UDV*
%	+ For each nonzero D(ii), we have the i-th column of U is in the orthonormal basis of the column space of M.
function orthoBasis = getOrthoBasis(inputMat, varargin)
	epsilon = 1e-12;		% Default value
	if nargin > 1
		epsilon = varargin{1};
	end
	
	if epsilon < 0
		epsilon = -epsilon;
	end
	epsilon = 1e-6;
	[rangeMat diagMat ~] = svd(inputMat);

	diagonal = diag(diagMat);

	indexSet = ~(diagonal < epsilon & diagonal > -epsilon);
	orthoBasis = rangeMat(:, indexSet);
end