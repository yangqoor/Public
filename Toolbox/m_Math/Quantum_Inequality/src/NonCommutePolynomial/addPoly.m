% The function: addPoly(P, Q)
%
% Input:
%	+ P and Q: objects or structure instances of type Polynomial.
%
% Ouput:
%	+ S = P + Q (sum of the polynomials P and Q)
%
% Note: The sum of two polynomials will be simplified.
%
% Assumption: the inputs are of the correct type (i.e. they have all required fields with correct format).
%
% Methodology:
%	1) Check if either one of them is the zero polynomial. If so, then everything is simple.
%	2) If not, check if P and Q are compatible for addition (i.e. if they have the same m_varProperties)
%	3) If they are compatible, then we just need to find the union of the two monomial lists. Other fields are guaranteed to be the same between the two
%		polynomials.
function sumPoly = addPoly(polyOne, polyTwo)
	if polyOne.m_degree < 0
		sumPoly = polyTwo;
		return;
	end
	if polyTwo.m_degree < 0
		sumPoly = polyOne;
		return;
	end

	if ~isequal(polyOne.m_varProperties, polyTwo.m_varProperties)
		error('The two polynomials are not compatible for addition');
	end

	sumPoly = polyOne;
	sumPoly.m_cellMonomial = [polyOne.m_cellMonomial, polyTwo.m_cellMonomial];

	sumPoly = simplifyPoly(sumPoly);
end