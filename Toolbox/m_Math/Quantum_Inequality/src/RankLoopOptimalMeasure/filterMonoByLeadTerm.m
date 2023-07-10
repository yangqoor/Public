% The function: filterMonoByLeadTerm(cellMono, varNo, parNo)
%
% Input:
%	+ cellMono: a cell of monomials.
%	+ varNo: an integer representing a variable.
% 	+ parNo: an integer representing a partition that the input variable belongs to.
%
% Output:
%	+ wantedIndex: the indices of monomials in cellMono such that the leading terms (with respect to the input partition) in their variable orderings are
%					varNo.
function wantedIndex = filterMonoByLeadTerm(cellMono, varNo, parNo)
	numMono = length(cellMono);

	wantedIndex = zeros(1, numMono);
	numSelect = 0;

	for index = 1 : numMono
		if ~isempty(cellMono{index}.m_varOrdering{parNo}) && cellMono{index}.m_varOrdering{parNo}(1) == varNo
			numSelect = numSelect + 1;
			wantedIndex(numSelect) = index;
		end
	end

	wantedIndex = wantedIndex(1 : numSelect);
end