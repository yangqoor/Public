% The function: chooseRandom(L, K)
%
% Input:
%	+ L: a vector / list of size 1 x n of some objects.
%	+ K: an integer
%
% The function will select randomly K elements from L.
%
% Output:
%	+ randList: a vector / list of size 1 x K of elements from L chosen randomly.

function randList = chooseRandom(inputList, numChosen)
	lenList = length(inputList);

	% randsample(N, K, false) generates a vector of K elements uniformly from [1 .. N] without replacement (i.e. there is no duplicate!)
	indexArr = randsample(lenList, numChosen, false);

	randList = inputList(indexArr);
end