% The function: createPolyObjForVar(varInfoHash, varProperties, varType, reducedVarHash)
%
% The function creates a polynomial structure (or object) that represents variables specified in varInfoHash and reducedVarHash
%
% Input:
%	+ varInfoHash: a hash table that maps a string to a pair of integers (X, Y) where
%			- X is a variable serial number (if a string is a name of a variable)
%			- Y is a partition serial number that the variable belongs to.
%
%	+ varProperties: this argument will be assigned to the field m_varProperties of a polynomial. 
%			   The length of varProp is the number of parties (or partitions)
%
%	+ varType: 0 or 1 (indicating the variables are projectors or observables)
%
%	+ reducedVarHash: (only applicable to the projector case and when all projectors are available) a hash table that maps the name of a redundant 
%			variable (in this case, we choose that last variable in each input group (or measurement setting)) to a vector of integers 
%			representing serial numbers of other variables in the same input group (or measurement setting).
%	  Note that the redundant variable = I - sum(M) where I is the identity and sum(M) is the sum of all other variables in the same input group with
%				the redundant variable.
%
% Output:
%	+ polyVarHash: a hash table that maps a string representing a variable name to its corresponding polynomial structure (or object). For convenience,
%		we also map 'I' to the identity constraint.
%
% Note: all polynomials representing variables will have the same varType and varProperties. This fact makes them compatible for addition and
%		multiplication.
function polyVarHash = createPolyObjForVar(varInfoHash, varProperties, varType, reducedVarHash)
	polyVarHash = containers.Map();

	cellVarName = keys(varInfoHash);

	numUsedVar = length(cellVarName);

	% cellVarNoToMono{i}: a monomial structure (object) representing the variable with serial number i
	cellVarNoToMono = cell(1, numUsedVar);

	numPartition = length(varProperties);

	% Create polynomial structures (objects) for used variables
	for index = 1 : numUsedVar
		cellVarOrder = cell(1, numPartition);
		% pairInfo(1): a variable serial number
		% pairInfo(2): a partition serial number that the variable belongs to.
		pairInfo = varInfoHash(cellVarName{index});
		cellVarOrder{pairInfo(2)} = pairInfo(1);
		cellVarNoToMono{pairInfo(1)} = NonCommuteMonomial(cellVarOrder, 1);
		polyVarHash(cellVarName{index}) = NonCommutePolynomial({cellVarNoToMono{pairInfo(1)}}, varProperties, varType);
	end

	% Create polynomial structures (objects) for unused variables
	cellUnusedVarName = keys(reducedVarHash);
	numUnused = length(cellUnusedVarName);
	for index = 1 : numUnused
		inputGroup = reducedVarHash(cellUnusedVarName{index});

		len = length(inputGroup);
		cellMono = cell(1, len + 1);
		cellMono(1 : len) = cellVarNoToMono(inputGroup);
		cellMono{len + 1} = NonCommuteMonomial(cell(1, numPartition), 1);		% The identity

		% Negate the coefficient
		for inner = 1 : len
			cellMono{inner}.m_coeff = -1;
		end

		polyVarHash(cellUnusedVarName{index}) = NonCommutePolynomial(cellMono, varProperties, varType);
	end

	if polyVarHash.isKey('I')
		error(sprintf('%s is reserved for the identity monomial. It must not be a variable name', 'I'));
	else
		identityMono = NonCommuteMonomial(cell(1, numPartition), 1);
		polyVarHash('I') = NonCommutePolynomial({identityMono}, varProperties, varType);
	end
end