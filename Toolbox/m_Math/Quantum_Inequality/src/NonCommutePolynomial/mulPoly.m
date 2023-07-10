% The function: mulPoly(P, Q)
%
% Input:
%	+ P and Q: objects or structure instances of type Polynomial.
%
% Ouput:
%	+ S = P * Q (product of the polynomials P and Q)
%
% Note: The product of two polynomials may not be in the simplest form. User has to called simplifyPoly separately to simplify the sum result.
%
% Assumption: the inputs are of the correct type (i.e. they have all required fields with correct format).
%
% Methodology:
%	1) First, check if either P or Q is a zero polynomial. If so, then the product is 0.
%	2) Otherwise, check if P and Q are compatible for multiplication (i.e. if they have the same m_varProperties)
%	2) If they are compatible
function productPoly = mulPoly(polyOne, polyTwo)
	if polyOne.m_degree < 0 || polyTwo.m_degree < 0
		productPoly = NonCommutePolynomial();
		return;
	end

	if ~isequal(polyOne.m_varProperties, polyTwo.m_varProperties)
		error('The two input polynomials are not compatible for multiplication');
	end

	numMonoOne = length(polyOne.m_cellMonomial);
	numMonoTwo = length(polyTwo.m_cellMonomial);
	productListMono = cell(1, numMonoOne * numMonoTwo);
	numProductMono = 0;

	for indexOne = 1 : numMonoOne
		for indexTwo = 1 : numMonoTwo
			numProductMono = numProductMono + 1;
			productListMono{numProductMono} = mulMonomial(polyOne.m_cellMonomial{indexOne}, polyTwo.m_cellMonomial{indexTwo}, polyOne.m_varType, polyOne.m_inputGroup); 
		end
	end

	productPoly = polyOne;
	productPoly.m_cellMonomial = productListMono(1 : numProductMono);
	productPoly = simplifyPoly(productPoly);
end