% The function: hasRankLoop(M, order, listMono, polyObj)
%
% This function is only applicable to projectors. Also, there should be only 2 parties.
%
% Input:
%	+ M: the moment matrix
%	+ order: the order (or level) of the semidefinite programming.
%	+ listMono: the list of monomials that the moment matrix M is indexed by (the order in listMono matters)
%	+ polyObj: the polynomial object representing your polynomial.
%
% Output:
%	+ rankLoop = 1 if there is a rank loop. Otherwise, rankLoop = 0.
%	+ rankMoment: the rank of the moment matrix in case there is a rank loop. Otherwise, the value of rankMoment is ignored!
%	+ epsilon: a cut-off threshold so that rankLoop can occur.
function [rankLoop rankMoment epsilon] = hasRankLoop(momentMatrix, order, listMono, polyObj)
	if order < 2
		% Rank loop is not applicable to the semidefinite program at level 1
		rankLoop = 'Rank loop is not applicable to the semidefinite program at level 1';
		rankMoment = 0;
		return;
	end

	varProperties = polyOp.m_varProperties;
	% Pre-processing:
	% Enumerate two lists containing variables in each partition.
	varParOne = cell2mat(varProperties{1});
	numParOne = length(varParOne);
	varParTwo = cell2mat(varProperties{2});
	numParTwo = length(varParTwo);

	epsilon = 1e-12;

	while epsilon < 1e-5
		rankMoment = computeRank(momentMatrix, epsilon);

		rankLoop = 1;		% Initialization
		for indexOne = 1 : numParOne
			for indexTwo = 1 : numParTwo
				indexSubMat = chooseSubMatForRankLoop(listMono, varParOne(indexOne), varParTwo(indexTwo), order);

				% Since the moment matrix M is Hermitian, submatrices of the form M(indexArr, indexArr) are Hermitian too!
				rankSubMat = computeRank(momentMatrix(indexSubMat, indexSubMat), epsilon);
		
				if rankSubMat ~= rankMoment
					% Rank loop does not occur
					rankLoop = 0;
					break;
				end
			end

			if ~rankLoop
				break;
			end
		end

		if rankLoop
			return;
		end

		epsilon = epsilon * 10;
	end

	% If the function reaches this point, rank loop does not occur
	rankLoop = 0;
end
