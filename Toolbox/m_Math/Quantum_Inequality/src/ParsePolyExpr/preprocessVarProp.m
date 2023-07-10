% preprocessVarProp(C, varType):
%
% Input:
%	+ C: a cell of size 1 x n where n is the number of partitions.
%		-If varType = 0 (Projector):
%			Each element in C is a cell of size 1 x m where m is the number of inputs of
%				the measurements.
%			Each cell has elements as cells. Each cell contains variable names.
%
%		- If varType = 1 (Observable):
%			Each element in C is a cell that contains names of variables in the same partition.
%	+ varType: 0 or 1 (indicating the variables are projectors or observables)
%	+ isFull: (This argument matters only in the projector case)
%		- isFull = 1 means all projector measurements are presented in C. Hence, the summing-to-identity property applies to those measurements that
%						belong to the same setting.
%		- isFull = 0 otherwise
%
% Output:
%	+ varInfoHash: a hash table that maps a variable name to a pair of integers (X, Y) where
%		- X: the variable serial number.
%		- Y: the partition serial number that this variable belongs to.
%
%	+ reducedVarHash: (only applicable to the projector case and when isFull = 1) a hash table that maps the name of a redundant variable (in this case,
%			we choose that last variable in each input group (or measurement setting)) to a vector of integers representing serial numbers of other
%			variables in the same input group (or measurement setting)
%
%	+ varProp: a cell of size 1 x n where n is the number of partitions.
%		-If varType = 0 (Projector):
%			Each element in C is a cell of size 1 x m where m is the number of inputs of
%				the measurements.
%			Each cell has elements as arrays. Each array contains variable serial numbers.
%
%		- If varType = 1 (Observable):
%			Each element in C is an array that contains variable serial numbers in the same partition.
function [varInfoHash, varProp, reducedVarHash] = preprocessVarProp(varPropWithName, varType, isFull)
	numPartition = length(varPropWithName);

	% Declare the hash table
	varInfoHash = containers.Map();
	reducedVarHash = containers.Map();
	varProp = cell(1, numPartition);
	varNo = 1;			% A serial number that is assigned to a variable.

	% Based on the value of varType, we have different schemes to pre-process the input.
	if varType
		% Observable case
		for partitionNo = 1 : numPartition
			% Partition Level
			partitionLength = length(varPropWithName{partitionNo});
			varProp{partitionNo} = zeros(1, partitionLength);

			for varIndex = 1 : partitionLength
				% Variable level
				varInfoHash(varPropWithName{partitionNo}{varIndex}) = [varNo partitionNo];
				varProp{partitionNo}(varIndex) = varNo;
				varNo = varNo + 1;
			end	
		end
	else
		% Projector case
		for partitionNo = 1 : numPartition
			% Partition Level
			numInputGroup = length(varPropWithName{partitionNo});
			varProp{partitionNo} = cell(1, numInputGroup);

			for inputGroupNo = 1 : numInputGroup
				% Input group level
				arrLength = length(varPropWithName{partitionNo}{inputGroupNo});

				numVar = arrLength;
				if isFull && arrLength > 1
					numVar = numVar - 1;
				end

				varProp{partitionNo}{inputGroupNo} = zeros(1, numVar);

				for varIndex = 1 : numVar
					% Variable level
					varInfoHash(varPropWithName{partitionNo}{inputGroupNo}{varIndex}) = [varNo partitionNo];
					varProp{partitionNo}{inputGroupNo}(varIndex) = varNo;
					varNo = varNo + 1;
				end

				if isFull && arrLength > 1
					% varPropWithName{partitionNo}{inputGroupNo}{arrLength} = the last variable in the current input group!
					reducedVarHash(varPropWithName{partitionNo}{inputGroupNo}{arrLength}) = varProp{partitionNo}{inputGroupNo};
				end
			end
		end	
	end
end
			