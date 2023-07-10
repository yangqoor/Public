% The function: chooseSubMatForRankLoop(cellMono, varParOne, varParTwo, order)
%
% Note: this is a helper function to hasRankLoop. This function is applicable to 2 parties only!
%
% Input:
%	+ cellMono: a cell of monomials whose degrees are less than or equal to order
%	+ varParOne: an integer representing a variable in the first partition.
%	+ varParTwo: an integer representing a variable in the second partition.
%	+ order: the order of the semidefinite program.
%
% Output:
%	+ shortListIndex: a list of indices of monomials in listMono such that
%		- In the variable ordering, the leading variables are varParOne and varParTwo.
%		- Or they have length order - 1
function shortListIndex = chooseSubMatForRankLoop(cellMono, varParOne, varParTwo, order)
	numMono = length(cellMono);
	listIndex = zeros(1, numMono);
	sizeList = 0;

	for index = 1 : numMono
		if cellMono{index}.m_degree == order - 1
			sizeList = sizeList + 1;
			listIndex(sizeList) = index;
		elseif ~isempty(cellMono{index}.m_varOrdering{1}) && ~isempty(cellMono{index}.m_varOrdering{2})
 			if cellMono{index}.m_varOrdering{1}(1) == varParOne && cellMono{index}.m_varOrdering{2}(1) == varParTwo
				sizeList = sizeList + 1;
				listIndex(sizeList) = index;
			end
		end
	end

	shortListIndex = listIndex(1 : sizeList);
end