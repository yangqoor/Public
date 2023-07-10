% The function: generatePartitionOrderProjector(varPartition, length)
% Input parameters:
%	+ varPartition:  a cell of size 1 x n where n is the number of 'input groups'. Elements are arrays. Each array contains distinct integers
%					 indicating the code of variables. All variables are projectors.
%	+ length: integer
%
% The function returns a cell 'cellOrdering' that contains all the orderings of all variables whose length is EXACTLY 'length'. Note that 
%	+ no two adjacent elements in the ordering are the same. It is because x * x = x when x is a projector. 
%	+ no two adjacent elements belong to the same 'input group'. It is because x * y = 0 if x and y are projectors whose inputs are the same.
%
% If length = 0 or List is empty, the function returns [].
% 
% Assumption: the inputs are in the correct format, (e.g. varPartition is not null)
% Methodology:
% 	+ Let N = length(varPartition)
%	+ If length == 0 or N == 0, return []
%	+ Else if N == 1 and length >= 2, return []
%	+ Let M<i> = length(varPartition{i})
%
% Essence of the problem: (Algorithm (1)) (Assume N >= 2)
% L1:	for a1 = 1 to N
% L2:		for a2 = 1 to M<a1> 																				
% L3:			for a3 = 1 to N and a3 ~= a1
% L4:				for a4 = 1 to M<a3>
% L5:					for a5 = 1 to N and a5 ~= a3
% L6:						for a6 = 1 to M<a5>
%								...
% L(2 * length - 1):			for a(2 * length - 1) = 1 to N and a(2 * length - 1) ~= a(2 * length - 3)
% L(2 * length):					for a(2 * length) = 1 to M<a(2 * length - 1)>
% L(2 * length + 1):					add the (length)-tuple (varPartition{a1}(a2), ..., varPartition{a(2 * length - 1)}(a(2 * length)) to cellOrdering
% 
% Since K = length is not a constant, the problem is to convert Algorithm (1) to an equivalent implementable version.
%
% Algorithm (2):
%	+ Note that in Algorithm (1), we have actually 2 * K + 1 levels. The first 2 * K levels are loops and level 2 * K + 1 is the action we need 
%     to perform.
%	+ Each loop (namely, loop i) will have a counter A(i) and an upperbound U(i)
%   + Each loop i where i is odd indicates the position in the ordering of length K.
%   + Each loop i where i is even is to choose a variable to fill position i - 1 in the ordering of length K.
%	+ Let O be a 1 x K array which indicates a satisfying ordering.
%
%	+ Let curLevel be a variable indicating the current level we are at. curLevel == 0 indicates the termination of the algorithm.
%   + Initially, set curLevel = 1 (we start at level 1). Set the variables for loop 1, i.e. A(1) = 1, U(1) = N
%	+ while curLevel >= 1
%		Go to the next level, i.e. curLevel = curLevel + 1
%
%		if we are at curLevel = 2 * K + 1 			// That means we need to perform the action 
%			add the K-tuples O to cellPartition
%			return to the previous loop level, i.e. curLevel = curLevel - 1.
%			set A(curLevel) = A(curLevel) + 1
%				- If curLevel is even:
%						* If A(curLevel) > U(curLevel), return to the previous level, i.e. curLevel = curLevel - 1.
%				- If curLevel is odd:
%						* If A(curLevel) == A(curLevel - 2) (when curLevel != 1), then A(curLevel) += 1.
%						* If A(curLevel) > U(curLevel), we continue to go up until counter <= N or we reach curLevel = 0
%
%			if(curLevel >= 1)
%				// Update the current possible ordering (only necessary when curLevel is even)
%				if curLevel is even
%					Set O(floor(curLevel / 2)) = varPartition{A(curLevel - 1)}(A(curLevel))		
%					// Note that curLevel / 2 is an integer (because curLevel is even), however, we use floor(curLevel / 2) for safety.
%		else
%			// We are at a loop level
%			if curLevel is odd
%				Set counter A(curLevel) = 1, U(curLevel) = N. If A(curLevel - 2) == 1, set A(curLevel) = 2.
%				Set U(curLevel) = N
%			if curLevel is even
%				Set counter A(curLevel) = 1, U(curLevel) = length(varPartition{A(curLevel})
%				Set O(floor(curLevel / 2)) = varPartition{A(curLevel - 1)}(A(curLevel))
%
% Time complexity: O(M^K) where K = length and M is the number of variables

function cellOrdering = generatePartitionOrderProjector(varPartition, len)
	N = length(varPartition);
	
	% Handle special cases
	if len == 0 || N == 0
		cellOrdering = cell(1, 1);
		return;
	end
	if N == 1 && len >= 2
		cellOrdering = cell(1, 1);
		return;
	end
	
	% Declare other variables
	Order = zeros(1, len);
	A = zeros(1, 2 * len);		% Counter of each loop
	U = zeros(1, 2 * len);		% Upperbound of each loop
	cellOrdering = {};
	curLvl = 1;
	% Prepare level 1
	A(1) = 1;
	U(1) = N;
	
	while curLvl >= 1
		% Go to the next level
		curLvl = curLvl + 1;
		
		if curLvl == 2 * len + 1			% Perform an action
			% Add a possible ordering to the result array
			cellOrdering{end + 1} = Order;
			
			% Simulate the loop backtracking
			curLvl = curLvl - 1;
			if curLvl >= 1
				A(curLvl) = A(curLvl) + 1;
				if mod(curLvl, 2) ~= 0 && curLvl > 1 && A(curLvl) == A(curLvl - 2)
					A(curLvl) = A(curLvl) + 1;
				end
			end
			while curLvl >= 1 && A(curLvl) > U(curLvl)
				curLvl = curLvl - 1;
				if curLvl >= 1
					A(curLvl) = A(curLvl) + 1;
					if mod(curLvl, 2) ~= 0 && curLvl > 1 && A(curLvl) == A(curLvl - 2)
						A(curLvl) = A(curLvl) + 1;
                    end
                end
			end
			if curLvl >= 1 && mod(curLvl, 2) == 0
				Order(floor(curLvl / 2)) = varPartition{A(curLvl - 1)}(A(curLvl));
			end
		else
			% We are at the new loop level. Do the settings for this loop
			if mod(curLvl, 2) == 0		% curLvl is even
				A(curLvl) = 1;
				U(curLvl) = length(varPartition{A(curLvl)});
				Order(floor(curLvl / 2)) = varPartition{A(curLvl - 1)}(A(curLvl));
			else						% curLvl is odd
				A(curLvl) = 1;
				if A(curLvl) == A(curLvl - 2)
					A(curLvl) = A(curLvl) + 1;
				end
				U(curLvl) = N;
			end
		end
	end
end