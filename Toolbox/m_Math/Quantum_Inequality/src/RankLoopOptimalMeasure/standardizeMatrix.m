% The function: standardizeMatrix(M, precision)
%
% Input:
%	+ M: a matrix
%	+ precision: a real-valued threshold. It should be positive!
%
% The function will standardize elements in the matrix:
%	+ Any element with the imaginary part close to zero within the threshold value will be set to a real number.
%	+ Any real-valued element that is close to zero within the threshold will be set to 0 with positive sign!
%
% Output:
%	+ standM: the standardized matrix
function standardMatrix = standardizedMatrix(matrix, varargin)
	if nargin < 2
		precision = 1e-12;
	else
		precision = varargin{1};
		if precision < 0
			precision = -precision;
		end
	end
	sizeMatrix = size(matrix);

	for row = 1 : sizeMatrix(1)
		for col = 1 : sizeMatrix(2)
			% Remove imaginary part if possible
			if imag(matrix(row, col)) < precision && imag(matrix(row, col)) > -precision
				matrix(row, col) = real(matrix(row, col));
			end

			% Standardize zero elements
			if isreal(matrix(row, col)) && matrix(row, col) < precision && matrix(row, col) > -precision
				matrix(row, col) = 0;
			end
		end
	end

	standardMatrix = matrix;
end