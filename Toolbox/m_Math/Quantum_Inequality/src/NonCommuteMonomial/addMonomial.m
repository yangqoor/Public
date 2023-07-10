% Method: addMonomial (Add two monomials)
% Returns the sum of two monomials that are compatible for addition
function addResult = addMonomial(monoOne, monoTwo)
	% Handle the case: monoOne or monoTwo is zero, i.e. its degree is less than 0
	if monoOne.m_degree < 0
		addResult = monoTwo;
		return;
	end
	if monoTwo.m_degree < 0
		addResult = monoOne;
		return;
	end
	
	epsilon = 1e-12;
	% Two monomials are compatible for addition if they have the same variable ordering!
	if isequal(monoOne.m_varOrdering, monoTwo.m_varOrdering)
		addResult = monoOne;
		addResult.m_coeff = monoOne.m_coeff + monoTwo.m_coeff;
		% Check if the result is a zero monomial
		if addResult.m_coeff < epsilon && addResult.m_coeff > -epsilon
			addResult.m_degree = -2147483648;
			addResult.m_varOrdering = cell(1,0);
		end
	else
		error('The two monomials are not compatible for addition');
	end
end