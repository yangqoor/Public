% The function: checkMomentVarValue(momentMatrix, inputPoly, cellMono, cellVarValue, stateVector)
%
% Inputs:
%	+ momentMatrix: the moment matrix in the SDP.
%	+ inputPoly: the polynomial structure which we want to optimize.
%	+ cellMono: an ordered list of monomials by which the moment matrix is indexed.
%	+ cellVarValue: a cell in which the i-th entry is the matrix representing the value of the variable of serial number i.
%	+ stateVector: a vector of the quantum states.
%
% Construct a matrix N such that N(i, j) = stateVector' * valueOf(cellMono{i}') * valueOf(cellMono{j}) * stateVector
%
% Outputs:
%	+ result = 1 if N == momentMatrix.
%	+ result = 0 otherwise.
%	+ epsilon: (In case result = 1) a positive real number. Any number x such that -epsilon < x < epsilon will be considered as 0. It is 
%				the tolerance for which result = 1
function [result epsilon] = checkMomentVarValue(momentMatrix, inputPoly, cellMono, cellVarValue, stateVector)
	epsilon = 1e-12;

	sizeMat = size(momentMatrix);
	compareMat = zeros(sizeMat);
	polyVarType = inputPoly.m_varType;
	polyInputGroup = inputPoly.m_inputGroup;

	for row = 1 : sizeMat(1)
		adjoint = getAdjoint(cellMono{row});

		for col = 1 : sizeMat(2)
			productMono = mulMonomial(adjoint, cellMono{col}, polyVarType, polyInputGroup);

			compareMat(row, col) = evaluateMonomial(productMono, cellVarValue, stateVector);
		end

	end

	diffMat = compareMat - momentMatrix;

	while epsilon < 1e-5
		result = isZeroMatrix(diffMat, epsilon);

		if result
			return;
		end

		epsilon = epsilon * 10;
	end

	result = 0;
end