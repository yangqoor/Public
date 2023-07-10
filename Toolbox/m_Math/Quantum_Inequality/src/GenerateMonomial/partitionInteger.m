% The function: partitionInteger(N, K)
% It partitions an integer N into K smaller non-negative integers [a1, a2, ..., aK] such that a1 + a2 + ... + aK = N.
% It returns an array arrPartition such that its elements are ways to partition N into K non-negative parts. If K <= 0
% (that means the input is not valid), the function returns the empty array.
%
% Note: arrPartition will have length of (N + K - 1)C(K - 1)
%
% Methodology:
% If K <= 0, we return the empty array.
% If K == 1, then we just return [N]
%
% Essence of the problem: (Algorithm (1)) (Assume K >= 2)
% L1:	for a1 = 0 to N																				
% L2:		for a2 = 0 to N - a1
% L3:			for a3 = 0 to N - a1 - a2
%					...
% L(K - 1):				for a(K - 1) = 0 to N - a1 - ... - a(K - 2)
% L(K):							add the K-tuple(a1, a2, ..., a(K - 1), N - a1 - ... - a(K - 1)) to arrPartition

% Since K is not a constant, the problem is to convert Algorithm (1) to an equivalent implementable version.
%
% Algorithm (2):
%	+ Note that in Algorithm (1), we have actually K levels. The first K - 1 levels are loops and level K is the action we need to perform.
%	+ Each loop (namely, loop i) will have a counter A(i) and an upperbound U(i)
%	
%	+ Let curLevel be a variable indicating the current level we are at. curLevel == 0 indicates the termination of the algorithm.
%   + Initially, set curLevel = 1 (we start at level 1). Set the variables for loop 1, i.e. A(1) = 0 and U(0) = N
%	+ while curLevel >= 1
%		Go to the next level, i.e. curLevel = curLevel + 1

%		if we are at curLevel = K 				// That means we need to perform the action 
%			Set A(K) = U(K - 1) - A(K - 1)		// The k-th component of the k-tuple.
%			add the K-tuples to arrPartition
%			return to the previous loop level, increase the counter. If counter > upperbound, we continue to go up until counter <= upperbound or 
%				we reach curLevel = 0
%		else
%			// We are at a loop level
%			Set counter A(curLevel) = 0 and U(curLevel) = U(curLevel - 1) - A(curLevel - 1)
%
% Time complexity: O[(N + L - 1)C(K - 1)]

function arrPartition = partitionInteger(N, K)
	if K <= 0
		arrPartition = [];
	elseif K == 1
		arrPartition = N;
	else
		% Declare and initialize variables
		U = zeros(1, K - 1);
		A = zeros(1, K);
		arrPartition = zeros(nchoosek(N + K - 1, K - 1), K);
		
		curLvl = 1;
		U(1) = N;
		curIndex = 0;		% curIndex indicates the index of the newest element in arrPartition
		while curLvl >= 1
			curLvl = curLvl + 1;
			
			if curLvl == K
				% We are at the bottom level
				% Add a k-tuple to the solution array
				A(K) = U(K - 1) - A(K - 1);
				curIndex = curIndex + 1;
				arrPartition(curIndex, :) = A;
				
				% Simulate loop backtracking
				curLvl = curLvl - 1;
				A(curLvl) = A(curLvl) + 1;
				while curLvl >= 1 && A(curLvl) > U(curLvl)
					curLvl = curLvl - 1;
					if curLvl >= 1
						A(curLvl) = A(curLvl) + 1;
					end
				end
			else
				% We are at a loop level. Set up its counter and upperbound
				A(curLvl) = 0;
				U(curLvl) = U(curLvl - 1) - A(curLvl - 1);
			end
		end
	end
end