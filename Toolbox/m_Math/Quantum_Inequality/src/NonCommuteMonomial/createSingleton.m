% Function: createSingleton(varNo, paritionNo, numPartition)
% 
% Create a singleton monomial structure.
function singletonMono = createSingleton(varNo, partitionNo, numPartition)
	varOrdering = cell(1, numPartition);
	varOrdering{partitionNo} = varNo;
	singletonMono = NonCommuteMonomial(varOrdering, 1);
end
