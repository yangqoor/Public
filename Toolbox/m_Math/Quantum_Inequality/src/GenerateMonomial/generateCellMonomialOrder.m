% The function: generateCellMonomial(order, list, varType, numPartitionPresent)
% Parameters:
%	+ order: integer
%	+ varType: 0 if variables are projectors; or 1 if variables are observables.
%	+ list: a cell of size 1 x n where K is the number of partitions. 
%		- If varType = 0, each element in the cell 'list' is also a cell. Its elements are arrays representing input groups. Each input group 
%         contains integers representing variables.
%		- If varType = 1, each element in the cell 'list' is an array which represents a partition. Each array contains integers which 
%		  represents variables.
%	Remark:
%		- If x and y are different projectors that belong to the same "input groups", x * y = 0
%		- The sum of all projectors within the same "input group" is I (identity)
%	+ numPartitionPresent: integer.
% 
% Assumption: length(list) = K >= 1
%
% The function returns a cell of monomials of non-negative degree exactly equal to the parameter 'order' whose variables of type 'varType' and 
% satisfied the conditions specified in the array 'list'. Also, variables in the monomials come from at least numPartitionPresent partitions.
%
% Assumption: order >= 0, length(list) >= 0

function cellMonomial = generateCellMonomialOrder(order, list, varType, numPartitionPresent)
	K = length(list);

	% If order = 0, return the identity monomial (i.e. a monomial of degree 0 and coefficient is 1)
	if order == 0
		cellMonomial = {NonCommuteMonomial(cell(1, K), 1)};
        return;
	end

	% If numPartitionPresent is not valid (i.e. numPartitionPresent > K (the total number of partitions) or numPartitionPresent > order), 
	% return an empty cell!
	if numPartitionPresent > K || numPartitionPresent > K
		cellMonomial = {};
		return;
	end
	
	% cellOrdering contains the ordering of variables in each partition
	cellOrdering = cell(1, K);
	cellMonomial = cell(1, 0);
    
	% First we partition order into K = length(list) non-negative integers. Also, there are at least numPartitionPresent positive integers among
	% the K integers!
	arrPartition = partitionIntegerCriteria(order, K, numPartitionPresent);
	
	% Each component in the K-tuple corresponds to the number of variables each partition can have in a monomial.
	sizeArr = size(arrPartition);
    numWay = sizeArr(1);                % The total number of partitions of upper into K parts
	for way = 1 : numWay
		for partitionNo = 1 : K
			if varType == 1
				% Observable case
				cellOrdering{partitionNo} = generatePartitionOrderObservable(list{partitionNo}, arrPartition(way, partitionNo));
			else
				% Projector case
				cellOrdering{partitionNo} = generatePartitionOrderProjector(list{partitionNo}, arrPartition(way, partitionNo));
			end
		end
			
		% Concatenate orderings of partitions to form monomials
		cellMonomial = [cellMonomial, concatenatePartitionOrdering(cellOrdering)];
	end
end
