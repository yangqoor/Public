% The function: evaluateMonomial(inputPoly, cellVarValue, stateVal)
% 
% Inputs:
%	+ inputPoly: a polynomial structure.
%	+ cellVarValue: a cell whose the i-th entry is a matrix representing a value of the variable of serial number i.
%	+ stateVal: a state vector.
%
% Assumptions: 
%	+ The inputs are in the correct format. 
%	+ The matrices and vectors are compatible for multiplication and addition.
%	+ The matrices should be Hermitian and have the same size.
%	+ The state vector is ideally pure.
%	+ cellVarValue should not be empty!
%
% Output:
%	+ valResult: the value of the polynomial evaluated at cellVarValue and stateVal.
function valResult = evaluatePolynomial(inputPoly, cellVarValue, stateVal)
	valResult = 0;

	numMono = length(inputPoly.m_cellMonomial);

	for index = 1 : numMono
		valResult = valResult + evaluateMonomial(inputPoly.m_cellMonomial{index}, cellVarValue, stateVal);
	end
end