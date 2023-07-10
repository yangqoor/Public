% The function: findProjection(M)
%
% Return the matrix representation of an orthogonal projection onto the space spanned by columns of M.
%
% Input:
%	+ M: a set of column vectors (v1, v2, ..., vn)
%
% Output:
%	+ P: the matrix representation of an orthogonal projection onto the space spanned by columns of M.
%
% Methodology:
%	+ Let W be the subspace spanned by v1, v2, ..., vn.
%	+ Find an orthnormal basis (w1, w2, ..., wk) of W.
%	+ Then the matrix representation of the projection onto W is:
%		P = sum(w(i) * w(i)') for i = 1, ..., k
function projection = findProjection(inputMat, epsilon)
	orthoBasis = getOrthoBasis(inputMat, epsilon);
	
	sizeMat = size(orthoBasis);
	numBasisVector = sizeMat(2);

	projection = orthoBasis(:, 1) * orthoBasis(:, 1)';
	for index = 2 : numBasisVector
		projection = projection + orthoBasis(:, index) * orthoBasis(:, index)';
	end
end