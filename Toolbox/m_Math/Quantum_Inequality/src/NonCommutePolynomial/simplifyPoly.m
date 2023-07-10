% The function: simplifyPoly(P)
%
% Input:
%	+ P: an object or structure instance of a polynomial
%
% Ouput:
%	+ simplePoly: an object or structure instance of a polynomial.
%
% The function simplifies the input polynomial P (i.e. it groups monomials that have the same variable ordering, but differ just in the coefficients).
%	The function also re-calculate the degree of the polynomial after the simplifying process.
%
% Methodology: Use hashing!
function simplePoly = simplifyPoly(inputPoly)
	if inputPoly.m_degree < 0
		% inputPoly is a zero polynomial
		simplePoly = NonCommutePolynomial();
	else
		monoHash = containers.Map();

		numMono = length(inputPoly.m_cellMonomial);

		for index = 1 : numMono
			strVarOrder = getMonoVarOrderStr(inputPoly.m_cellMonomial{index});

			if monoHash.isKey(strVarOrder)
				monoHash(strVarOrder) = addMonomial(monoHash(strVarOrder), inputPoly.m_cellMonomial{index});
			else
				monoHash(strVarOrder) = inputPoly.m_cellMonomial{index};
			end
		end

		% Restore all the distinct monomials.
		allMono = values(monoHash);
		numAllMono = length(allMono);
		selectedMono = cell(1, numAllMono);
		numSelect = 0;
		for index = 1 : numAllMono
			if allMono{index}.m_degree >= 0
				% The monomial is not zero
				numSelect = numSelect + 1;
				selectedMono{numSelect} = allMono{index};
			end

		if numSelect == 0
			% All monomials are zero. So we create a zero polynomial
			simplePoly = NonCommutePolynomial();
		else
			simplePoly = NonCommutePolynomial(selectedMono(1 : numSelect), inputPoly.m_varProperties, inputPoly.m_varType, inputPoly.m_inputGroup, inputPoly.m_numVar);			
		end
	end
end