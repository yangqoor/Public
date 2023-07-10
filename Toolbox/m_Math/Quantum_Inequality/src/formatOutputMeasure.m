% The function: formatOutputMeasure(cellVarValue, varPropWithName, varType)
%
% Inputs:
%	+ cellVarValue: a cell where the i-th element is the matrix value of the variable whose serial number is i.
%	+ varType: a string whose value is either 'projector' or 'observable'
%	+ varPropWithName: a cell of size 1 x n where n is the number of partitions.
%		-If varType = 'projector':
%			Each element in varPropWithName is a cell of size 1 x m where m is the number of inputs of
%				the measurements.
%			Each cell has elements as cells. Each cell contains variable names.
%
%		- If varType = 'observable':
%			Each element in varPropWithName is a cell that contains names of variables in the same partition.
%
% Note: varPropWithName should be the same as the input argument to the function createPolyFromExpr.
% 		Ideally, cellVarValue is the return result of getOptimalProjector or getOptimalObservable functions.
% 
% Assumption: All matrices in cellVarValue should be square matrices of the same size.
%
% Output:
%	+ hashVarNameVal: a hash table which maps the variable name to its matrix value.
function hashVarNameVal = formatOutputMeasure(cellVarValue, varPropWithName, varType)
	hashVarNameVal = containers.Map();
	sizeMat = size(cellVarValue{1});
	orderMat = sizeMat(1);

	varCount = 1;
	numPartition = length(varPropWithName);
	if strcmpi(varType, 'observable')
		for parNo = 1 : numPartition
			numVar = length(varPropWithName{parNo});
			for varNo = 1 : numVar
				hashVarNameVal(varPropWithName{parNo}{varNo}) = cellVarValue{varCount};
				varCount = varCount + 1;
			end
		end
	elseif strcmpi(varType, 'projector')
		% First, determine if varPropWithName contains a full or partial list of variables by comparing
		%	the total number of variables in varPropWithName and cellVarValue
		numVarPoly = length(cellVarValue);

		numVar = 0;
		for parNo = 1 : numPartition
			numInputGroup = length(varPropWithName{parNo});

			for inputGroup = 1 : numInputGroup
				numVar = numVar + length(varPropWithName{parNo}{inputGroup});
			end
		end

		identity = eye(orderMat);

		for parNo = 1 : numPartition
			numInputGroup = length(varPropWithName{parNo});

			for inputGroup = 1 : numInputGroup
				numVarPerGroup = length(varPropWithName{parNo}{inputGroup});

				sumMat = zeros(orderMat);
				for varNo = 1 : (numVarPerGroup - 1)
					hashVarNameVal(varPropWithName{parNo}{inputGroup}{varNo}) = cellVarValue{varCount};
					sumMat = sumMat + cellVarValue{varCount};
					varCount = varCount + 1;
				end

				if numVarPoly ~= numVar
					% Full list Case
					hashVarNameVal(varPropWithName{parNo}{inputGroup}{numVarPerGroup}) = identity - sumMat;
				else
					% Partial list Case
					hashVarNameVal(varPropWithName{parNo}{inputGroup}{numVarPerGroup}) = cellVarValue{varCount};
					varCount = varCount + 1;
				end
			end
		end
	else
		error('Variable type should be either PROJECTOR or OBSERVABLE');
	end
end