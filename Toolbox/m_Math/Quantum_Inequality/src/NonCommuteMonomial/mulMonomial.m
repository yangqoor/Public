% Method: mulMonomial (Multiply two monomials)
% This method also considers the type of variables. 
%       If typeNo = 0, variables are projectors (i.e. x * x = x)
%		If typeNo = 1, variables are observables (i.e. x * x = Id)
% In case varType = 0, the method takes in an array groupByInput such that two variables with numbers x and y
% are projectors that take in the same input, but produce different measurement outputs if and only if
% groupByInput(x) = groupByInput(y)
% In case varType = 1, groupByInput is empty
function mulResult = mulMonomial(monoOne, monoTwo, typeVar, groupByInput)
	% Consider the case one of the two input monomials are zero
	if monoOne.m_degree < 0 || monoTwo.m_degree < 0
		% Create a zero monomial
		mulResult = NonCommuteMonomial();
		return;
	end
		
	% Compute the coefficient of the multiplication result
    mulResult.m_coeff = monoOne.m_coeff * monoTwo.m_coeff;
	mulResult.m_degree = monoOne.m_degree + monoTwo.m_degree;
	
	% We are computing monoOne * monoTwo.
	% Thus, concatenate each ordering of each partition in monoTwo to the corresponing ordering in monoOne.
	numPartition = length(monoOne.m_varOrdering);
	mulResult.m_varOrdering = cell(1, numPartition);
	for i = 1 : numPartition
		% Note that this step does not update the degree. However, the degree will be recalculated when
		% we reduce monoOne. Hence, the resulting monomial is still valid.
		mulResult.m_varOrdering{i} = [monoOne.m_varOrdering{i}, monoTwo.m_varOrdering{i}];
	end
	
	% Reduce and recalculate the degree!
	mulResult = reduceMonomial(mulResult, typeVar, groupByInput);
end