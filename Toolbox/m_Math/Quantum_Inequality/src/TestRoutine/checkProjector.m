% The function: checkProjector(cellVarValue, inputPoly)
%
% Inputs:
%	+ cellVarValue: a cell in which the i-th entry is the matrix representing the value of the variable of serial number i.
%	+ inputPoly: the polynomial structure which we want to optimize.
%
% Note: For the projector case:
%	+ inputPoly.m_varProperties: is a cell of size 1 x n where n is the number of partitions.
%			- Each element in m_varProperties is a cell of size 1 x m where m is the number of inputs of
%				the measurements.
%			- Each cell has elements as arrays. Each array contains integers representing variables.
% Outputs:
%	+ result = 1 if the matrices in cellVarValue satisfy the orthogonality constraint of projectors, i.e.
%				A * A = A and
%				A * B = 0 if A and B are in the same input group (or has the same setting).
%	+ result = 0 otherwise.
%	+ epsilon: (In case result = 1) a positive real number. Any number x such that -epsilon < x < epsilon will be considered as 0. It is 
%				the tolerance for which result = 1
function [result epsilon] = checkProjector(cellVarValue, inputPoly)
	varProp = inputPoly.m_varProperties;

	numPartition = length(varProp);
	cellMat = {};

	for parNo = 1 : numPartition
		numInputGroup = length(varProp{parNo});

		for inputGroupNo = 1 : numInputGroup
			numVarPerGroup = length(varProp{parNo}{inputGroupNo});

			for indexOne = 1 : numVarPerGroup
				varOne = varProp{parNo}{inputGroupNo}(indexOne);
				for indexTwo = indexOne : numVarPerGroup
					varTwo = varProp{parNo}{inputGroupNo}(indexTwo);
					if varOne == varTwo
						cellMat{end + 1} = cellVarValue{varOne} * cellVarValue{varOne} - cellVarValue{varOne};
					else
						cellMat{end + 1} = cellVarValue{varOne} * cellVarValue{varTwo};
						cellMat{end + 1} = cellVarValue{varTwo} * cellVarValue{varOne};
					end
				end
			end
		end
	end

	numMat = length(cellMat);

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

		epsilon = epsilon * 10;
	end

	result = 0;
end