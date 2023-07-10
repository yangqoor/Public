% The function: concatenatePartitionOrdering(listPartitionOrdering)
% Input parameter:
%	+ listPartitionOrdering: a cell of size 1 x n where n is the number of partitions. Each element is a cell of possible orderings
%			of length L(i) (i = 1, ..., n) in a partition.
% 
% The function returns a cell of monomials cellMonomial created by concatenating the oderings of partitions.
%
% Assumption: length(listPartitionOrdering >= 1) and the input is in the correct format (e.g. it is a cell of cells of arrays)
%
% Methodology:
% 	+ Let N = length(listPartitionOrdering)
%	+ If N == 0
%		return the zero monomial.
%   + Let L(i) = length(listPartitionOrdering{i})
%	+ Note that cellMonomial is of size L(1) * L(2) * ... * L(N)
%
% Essence of the problem: (Algorithm (1)) (Assume N >= 2)
% L1:	for a1 = 1 to L(1)																				
% L2:		for a2 = 1 to L(2)
% L3:			for a3 = 1 to L(3)
%					...
% L(N):					for a(N) = 1 to L(N)
% L(N + 1):					create a monomial whose ordering is {listPartitionOrdering{1}{a1}, ..., listPartitionOrdering{1}(aN)}
%								and coefficient is 1 and add it to cellMonomial.
%
% Since N is not a constant, the problem is to convert Algorithm (1) to an equivalent implementable version.
%
% Algorithm (2):
%	+ Note that in Algorithm (1), we have actually N + 1 levels. The first N levels are loops and level N + 1 is the action we need to perform.
%	+ Each loop (namely, loop i) will have a counter A(i) and an upperbound U(i)
%	+ Let O be a 1 x N cell which indicates a satisfying ordering of a monomial.
%
%	+ Let curLevel be a variable indicating the current level we are at. curLevel == 0 indicates the termination of the algorithm.
%   + Initially, set curLevel = 1 (we start at level 1). Set the variables for loop 1, i.e. 
%                        A(1) = 1, U(1) = length(listPartitionOrdering{1}) and O(1) = listPartitionOrdering{1}{A(1)}
%	+ while curLevel >= 1
%		Go to the next level, i.e. curLevel = curLevel + 1
%
%		if we are at curLevel = N + 1 			// That means we need to perform the action 
%			reate a monomial whose ordering is O and coefficient is 1 and add it to cellMonomial.
%
%			return to the previous loop level (i.e. curLevel = curLevel - 1), increase the counter (i.e. A(curLevel) = A(curLevel) + 1) 
%				- If A(curLevel) > U(curLevel), we continue to go up until counter <= U(curLevel) or we reach curLevel = 0
%			if curLevel >= 1
%				// Update the current possible ordering
%				Set O(curLevel) = listPartitionOrdering{curLevel}{A(curLevel)} and prepare to do the next loop
%		else
%			// We are at a loop level
%			Set counter A(curLevel) = 1.
%			Set upper boud U(curLevel) = length(listPartitionOrdering{curLevel})
%			Set O(curLevel) = listPartitionOrdering{curLevel}{A(curLevel)}
% Time complexity: O(L(1) * L(2) * ... * L(N))

function cellMonomial = concatenatePartitionOrdering(listPartitionOrdering)
	N = length(listPartitionOrdering);
	if N == 0
		cellMonomial = {NonCommuteMonomial()};
		return;
	end
	
	% Delcare and initialize other variables
	totalMonomial = 1;
	for index = 1 : N
		totalMonomial = totalMonomial * length(listPartitionOrdering{index});
	end
	cellMonomial = cell(1, totalMonomial);
	Order = cell(1, N);
	A = zeros(1, N);
	U = zeros(1, N);
	curNumMonomial = 0;
	% Intialize the first loop level
	curLvl = 1;
	A(1) = 1;
	U(1) = length(listPartitionOrdering{1});
	Order{1} = listPartitionOrdering{1}{A(1)};
	
	while curLvl >= 1
		% Go to the next level
		curLvl = curLvl + 1;
		
		if curLvl == N + 1			% Perform an action
			% create a monomial whose ordering is Order and coefficient is 1 and add it to cellMonomial
			curNumMonomial = curNumMonomial + 1;
			cellMonomial{curNumMonomial} = NonCommuteMonomial(Order, 1);
			
			% Simulate the loop backtracking
			curLvl = curLvl - 1;
			if curLvl >= 1
				A(curLvl) = A(curLvl) + 1;
			end
			while curLvl >= 1 && A(curLvl) > U(curLvl)
				curLvl = curLvl - 1;
				if curLvl >= 1
					A(curLvl) = A(curLvl) + 1;
                end
			end
			if curLvl >= 1
				Order{curLvl} = listPartitionOrdering{curLvl}{A(curLvl)};
			end
		else
			% We are at the new loop level. Do the settings for this loop
			A(curLvl) = 1;
			U(curLvl) = length(listPartitionOrdering{curLvl});
			Order{curLvl} = listPartitionOrdering{curLvl}{A(curLvl)};
		end
	end
end
