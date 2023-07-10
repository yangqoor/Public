% Method: reduceMonomial
% The method will reduce a monomial by the property of its variables.
% 	+ If variables are projectors (varType = 0), then
%           x * x = x
%			x * y = 0 if x, y are projectors that take in the same input,
%						 but produce different measurement outputs.
%   + If variables are observables (varType = 1), then
%			x * x = Id
% In case varType = 0, the method takes in an array groupByInput such that two variables with numbers x and y
% are projectors that take in the same input, but produce different measurement outputs if and only if
% groupByInput(x) = groupByInput(y)
% In case varType = 1, groupByInput is empty
function reduceMono = reduceMonomial(mono, varType, groupByInput)
	% If a monomial is zero or of degree zero, no need to reduce it!
	if mono.m_degree <= 0
		reduceMono = mono;
		return;
    end
            
	% Projector case
	% Check the case if there exist x, y such that x # y and  x * y = 0 first
	if ~varType
		for i = 1 : length(mono.m_varOrdering)
			for j = 2 : length(mono.m_varOrdering{i})
				if mono.m_varOrdering{i}(j) ~= mono.m_varOrdering{i}(j - 1) && groupByInput(mono.m_varOrdering{i}(j)) == groupByInput(mono.m_varOrdering{i}(j - 1))
					% Zero polynomial
					reduceMono = NonCommuteMonomial();
					return;
				end
			end
		end
	end
		
	% At this point, we know that a reduced monomial cannot be zero. Then we call removeDup function.
	% removeDup function is designed to simulate the process of monomial reduction with properties
	% x * x = Id (if x is an observable) and x * x = x (if x is a projector).
	reduceMono.m_coeff = mono.m_coeff;
	
	numPartition = length(mono.m_varOrdering);
	totalLen = 0;
	reduceMono.m_varOrdering = cell(1, numPartition);
	for i = 1 : numPartition
		[newVarOrder, newLen] = removeDup(mono.m_varOrdering{i}, varType);
		reduceMono.m_varOrdering{i} = newVarOrder;
		totalLen = totalLen + newLen;
	end

	reduceMono.m_degree = totalLen;
end