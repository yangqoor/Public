% The function: choleskyDecompose(M, precision, flagCheckInput)
%
% Input:
%	+ M: a square matrix.
%	+ precision: a real-value threshold. It should be positive. Those numbers R that satisfy -precision < R < precision will be considered as 0.
%
% The function returns an upper triangular matrix L such that L' * L = M (where L' is the conjugate transpose of L) assumed that 
%			M is positive semidefinite.
%
% Output:
%	+ A square matrix L such that L' * L = M if M is positive semi-definite.
%	+ If M is not positive semi-definite, the function returns [] (empty matrix) (So this function can be used to test positive semi-definite property)
function cholesky = choleskyDecompose(inputMat, varargin)
	precision = 1e-12;		% Default value
	
	if nargin > 1
		precision = varargin{1};
	end

	if precision < 0
		precision = -precision;
	end

	dimension = size(inputMat);

	if dimension(1) ~= dimension(2)
		error('The input matrix must be a square matrix!');
	end

	if ~isequal(inputMat', inputMat)
		error('The input matrix must be Hermitian!');
	end

	% Find the Cholesky decomposition of inputMat
	% Algorithm used: Cholesky–Banachiewicz algorithm (which starts from the upper left corner of the matrix L and proceeds to calculate 
	%						the matrix row by row).
	cholesky = zeros(dimension);		% cholesky is an upper triangular matrix!
	
	for row = 1 : dimension(1)
		% Compute the diagonal entries
		square = inputMat(row, row) - cholesky(1 : row - 1, row)' * cholesky(1 : row - 1, row);

		if square < precision && square > -precision
			% square = 0
			cholesky(row, row : dimension(1)) = 0;
		elseif square < -precision
			error('The input matrix must be positive semi-definite!');
		else
			cholesky(row, row) = sqrt(square);

			for col = row + 1 : dimension(1)
				cholesky(row, col) = 1 / cholesky(row, row) * (inputMat(row, col) - cholesky(1 : row - 1, row)' * cholesky(1 : row - 1, col));
			end 
		end	
	end

	%cholesky = standardizeMatrix(cholesky, precision);
end