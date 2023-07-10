% The function: isPositiveSemidefinite(mat, epsilon)
% 
% Inputs:
%	+ mat: a matrix
%	+ epsilon: a positive real number. Any number x such that -epsilon < |x| < epsilon will be considered as 0.
%
% Output:
% 	+ result = 1 if mat is positive semidefinite.
%	+ result = 0 otherwise.
%
% Methodology:
%	+ A is a positive semidefinite matrix if and only if
%		- A = A' 
%		- All eigenvalues of A must be non-negative.
function result = isPositiveSemidefinite(mat, epsilon)
	sizeMat = size(mat);

	if sizeMat(1) ~= sizeMat(2)
		result = 0;
		return;
	end

	if ~isZeroMatrix(mat - mat', epsilon)
		result = 0;
		return;
	end

	eigenArr = eig(mat)

	numEigen = length(eigenArr);

	for index = 1 : numEigen
		if abs(imag(eigenArr(index))) > epsilon || real(eigenArr(index)) < -epsilon
			% If the eigenvalue is imaginary or it is a real negative number, then the matrix is not positive semidefinite!
			result = 0;
			return;
		end
	end

	result = 1;
end