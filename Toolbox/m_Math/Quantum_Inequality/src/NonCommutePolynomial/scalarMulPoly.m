% The function: scalarMulPoly(inputPoly, scalar)
%
% The function multiplies a scalar to a polynomial.
%
% Input:
%	+ inputPoly: a polynomial structure (or object).
%	+ scalar: a real number.
%
% Ouput:
%	+ resultPoly
function resultPoly = scalarMulPoly(inputPoly, scalar)
	if inputPoly.m_degree < 0
		% inputPoly is a zero polynomial
		resultPoly = inputPoly;
		return;
	end

	epsilon = 1e-12;
	if scalar < epsilon && scalar > -epsilon
		% scalar = 0
		resultPoly = NonCommutePolynomial();		% The zero polynomial
		return;
	end

	numMono = length(inputPoly.m_cellMonomial);
	resultPoly = inputPoly;
	for index = 1 : numMono
		resultPoly.m_cellMonomial{index}.m_coeff = resultPoly.m_cellMonomial{index}.m_coeff * scalar;
	end
end