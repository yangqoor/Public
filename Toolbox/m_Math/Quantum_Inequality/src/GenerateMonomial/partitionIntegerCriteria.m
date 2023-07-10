% The function: partitionIntegerCriteria(N, K, C)
%
% It partitions an integer N into K smaller non-negative integers [a1, a2, ..., aK] such that a1 + a2 + ... + aK = N. Also there are C positive integers
% 	among a1, a2, ..., aK
%
% It returns an array arrPartition such that 
%		1) its elements are ways to partition N into K non-negative parts
%		2) there are at least C positive parts among a1, a2, ..., aK. 
%
% If K <= 0 (that means the input is not valid), the function returns the empty array.
%
% Time complexity: O[(N + L - 1)CHOOSE(K - 1)]

function arrPartition = partitionInteger(N, K, numPositive)
	firstRoundArr = partitionInteger(N, K);

	dimension =  size(firstRoundArr);
	numSol = dimension(1);

	satisfySol = zeros(1, numSol);
	numSatisfy = 0;

	for curSol = 1 : numSol
		if sum(firstRoundArr(curSol, :) > 0) >= numPositive
			numSatisfy = numSatisfy + 1;
			satisfySol(numSatisfy) = curSol;
		end
	end

	arrPartition = firstRoundArr(satisfySol(1 : numSatisfy), :);
end