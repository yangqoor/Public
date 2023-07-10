% The function: evaluateMonomial(mono, cellVarValue, stateVal)
% 
% Inputs:
%	+ mono: a monomial structure.
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
%	+ valResult: the value of the monomial evaluated at cellVarValue and stateVal.
function valResult = evaluateMonomial(mono, cellVarValue, stateVal)
	% Case 1: Zero monomial
	if mono.m_degree < 0
		valResult = 0;
		return;
	end

	% Case 2: Multiple of identity monomial
	if mono.m_degree == 0
		valResult = mono.m_coeff * stateVal' * stateVal;
		return;
	end

	% Other cases
	varOrder = cell2mat(mono.m_varOrdering);
	% Since mono.m_degree > 0 at this point, varOrder is not empty!
	matrixVal = cellVarValue{varOrder(1)};
	numTerm = length(varOrder);

	for index = 2 : numTerm
		matrixVal = matrixVal * cellVarValue{varOrder(index)};
	end

	valResult = mono.m_coeff * stateVal' * matrixVal * stateVal;

end
