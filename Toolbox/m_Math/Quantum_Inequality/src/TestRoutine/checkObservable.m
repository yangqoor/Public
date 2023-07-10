% The function: checkObservable(cellVarValue)
%
% Inputs:
%	+ cellVarValue: a cell in which the i-th entry is the matrix representing the value of the variable of serial number i.
%
% Assumption:
%	+ cellVarValue is not empty.
%
% Outputs:
%	+ result = 1 if the matrices in cellVarValue satisfy properties of observables, i.e. A * A = I
%	+ result = 0 otherwise.
%	+ epsilon: (In case result = 1) a positive real number. Any number x such that -epsilon < x < epsilon will be considered as 0. It is 
%				the tolerance for which result = 1
function [result epsilon] = checkObservable(cellVarValue)
	cellMat = {};

	numMat = length(cellVarValue);
	identity = eye(size(cellVarValue{1}));

	for index = 1 : numMat
		cellMat{end + 1} = identity - cellVarValue{index} * cellVarValue{index};
	end

	epsilon = 1e-12;

	while epsilon < 1e-5
		result = 1;
		for index = 1 : numMat
			if ~isZeroMatrix(cellMat{index}, epsilon)
				result = 0;
				break;
			end
		end

		if result
			return;
		end

		epsilon = epsilon * 10;
	end

	result = 0;
end