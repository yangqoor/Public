% The function: generatePartitionOrderObservable(varPartition, length)
% Input parameters:
%	+ varPartition:  a array of size 1 x n where n is the number of variable in a partition. Elements are distinct integers which represent variables.
%					 All variables are observables.
%	+ length: integer
%
% The function returns a cell 'cellOrdering' that contains all the orderings of n such variables whose length is EXACTLY 'length'. Note that no two 
% adjacent elements in the ordering are the same. It is because x * x = Identity when x is an observable. 
% If length = 0 or List is empty, the function returns [].
% 
% Assumption: the inputs are in the correct format, (e.g. varPartition is not null)
%
% Methodology:
% 	+ Let N = length(varPartition)
%	+ If length == 0 or N == 0, return []
%	+ Else if N == 1 and length == 1, return varPartition(1)
%	+ Else if N == 1 and length >= 2, return []
%
% Essence of the problem: (Algorithm (1)) (Assume N >= 2)
% L1:	for a1 = 1 to N																				
% L2:		for a2 = 1 to N and a2 ~= a1
% L3:			for a3 = 1 to N and a3 ~= a2
%					...
% L(length):			for a(length) = 1 to N and a(length) ~= a(length - 1)
% L(length + 1):			add the (length)-tuple (varPartition(a1), ..., varPartition(a(length)) to cellOrdering
% 
% Since K = length is not a constant, the problem is to convert Algorithm (1) to an equivalent implementable version.
%
% Algorithm (2):
%	+ Note that in Algorithm (1), we have actually K + 1 levels. The first K levels are loops and level K + 1 is the action we need to perform.
%	+ Each loop (namely, loop i) will have a counter A(i) and an upperbound N
%	+ Let O be a 1 x K array which indicates a satisfying ordering.
%
%	+ Let curLevel be a variable indicating the current level we are at. curLevel == 0 indicates the termination of the algorithm.
%   + Initially, set curLevel = 1 (we start at level 1). Set the variables for loop 1, i.e. A(1) = 1 and O(1) = varPartition(A(1))
%	+ while curLevel >= 1
%		Go to the next level, i.e. curLevel = curLevel + 1
%
%		if we are at curLevel = K + 1 			// That means we need to perform the action 
%			add the K-tuples O to cellOrdering
%			return to the previous loop level, increase the counter. 
%				- If A(curLevel) == A(curLevel - 1) (when curLevel != 1), then A(curLevel) += 1.
%				- If A(curLevel) > N, we continue to go up until counter <= N or we reach curLevel = 0
%			if curLevel >= 1
%				// Update the current possible ordering
%				Set O(curLevel) = varPartition(A(curLevel)) and prepare to do the next loop
%		else
%			// We are at a loop level
%			Set counter A(curLevel) = 1. If A(curLevel - 1) == 1, set A(curLevel) = 2.
%			Set O(curLevel) = varPartition(A(curLevel))
% Time complexity: O(N^K) where K = length

function cellOrdering = generatePartitionOrderObservable(varPartition, len)
	N = length(varPartition);
    
	% Handle special cases
	if len == 0 || N == 0
		cellOrdering = cell(1, 1);
		return;
	end
	if N == 1
		if len == 1
            cellOrdering = {varPartition(N)};
		else
			cellOrdering = cell(1, 1);
		end
		return;
    end
    
	% Declare other variables
	Order = zeros(1, len);
	A = zeros(1, len);
	cellOrdering = {};
	curLvl = 1;
	% Prepare level 1
	A(1) = 1;
	Order(1) = varPartition(1);
	
	while curLvl >= 1
		% Go to the next level
		curLvl = curLvl + 1;
		
		if curLvl == len + 1			% Perform an action
			% Add a possible ordering to the result array
			cellOrdering{end + 1} = Order;
			% Simulate the loop backtracking
			curLvl = curLvl - 1;
			if curLvl >= 1
				A(curLvl) = A(curLvl) + 1;
				if curLvl > 1 && A(curLvl) == A(curLvl - 1)
					A(curLvl) = A(curLvl) + 1;
				end
			end
			while curLvl >= 1 && A(curLvl) > N
				curLvl = curLvl - 1;
				if curLvl >= 1
					A(curLvl) = A(curLvl) + 1;
					if curLvl > 1 && A(curLvl) == A(curLvl - 1)
						A(curLvl) = A(curLvl) + 1;
                    end
                end
			end
			if curLvl >= 1
				Order(curLvl) = varPartition(A(curLvl));
			end
		else
			% We are at the new loop level. Do the settings for this loop
			A(curLvl) = 1;
			if A(curLvl) == A(curLvl - 1)
				A(curLvl) = A(curLvl) + 1;
            end
			Order(curLvl) = varPartition(A(curLvl));
		end
	end
end
	 