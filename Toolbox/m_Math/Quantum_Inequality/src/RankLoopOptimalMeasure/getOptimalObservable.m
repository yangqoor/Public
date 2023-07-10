% The function: getOptimalObservable(M, polyObj, positionHash)
%
% Important note: This function is only applicable to two-party cases only!
%
% Inputs:
%	+ M: the moment matrix.
% 	+ polyObj: the polynomial object representing the polynomial you want to optimize
%	+ positionHash: a hash table that maps a string representing the variable ordering of a monomial to the monomial's location (row, column) 
%		in the moment matrix.
%
%		Note that if a monomial is a singleton, by our construction of the moment matrix and positionHash in the function findQuantumBound, the location
%		of the singleton monomial is of the form (1, h) for some column h in the moment matrix!
%
% Outputs:
%	+ cellObsevable: a cell of size N(where N is the total number of observables). cellObservable{i} (i >= 1) is the explicit observable whose 
%							serial number is i.
%	+ opState: the optimal state
%
% Methodology:
%	+ Find the Cholesky decomposition of M, i.e. the matrix R such that (R*)R = M (R* is the conjugate transpose of R)
%	+ Let R = (v1 v2 ... vk) where k = order. Then we have 
%   + Generate the Clifford algebra (T1, T2, ..., Tk)
function [cellObservable opState]=  getOptimalObservable(momentMatrix, polyObj, positionHash)
	sizeMat = size(momentMatrix);
	order = sizeMat(1);

	% Find the observables explicitly
	cholDecompose = choleskyDecompose(momentMatrix, 1e-10, 1);

	% Generate a cell of monomials of order 1 (e.g. a cell of variables)
	cellVar = generateCellMonomialOrder(1, polyObj.m_varProperties, polyObj.m_varType, 0);
	
	% Declare some variables that will be used throughout the function!
	numVar = length(cellVar);
	sizeOp = 2 ^ (floor(order / 2));
	identity = eye(sizeOp);

	% Pre-allocate the output
	cellObservable = cell(1, numVar);

	% Generate the Clifford algebra
	cellClifford = generateClifford(order);

	% Find the observables explicitly
	% Note that we deal with 2-party cases only.
	for varIndex = 1 : numVar
		% For each variable, we find its matrix representation.
		% Note that each variable is a singleton monomial (of degree 1) and we have two partitions only
		varOrderStr = getMonoVarOrderStr(cellVar{varIndex});
		% Find its location in the moment matrix. The coordinates should be in the form (1, d)
		coordinate = positionHash(varOrderStr);
		if coordinate(1) ~= 1
			error('Something is wrong with the algorithm (particularly with the function findQuantumBound!');
		end

		observableOp = zeros(sizeOp);
		for index = 1 : order
			observableOp = observableOp + cholDecompose(index, coordinate(2)) * cellClifford{index};
		end

		% Note that observables are stored from index 2 onwards in the output!
		if ~isempty(cellVar{varIndex}.m_varOrdering{1})
			% If the variable belongs to the first party, take the tranpose (NOT conjugate transpose)
			observableOp = transpose(observableOp);
			cellObservable{cellVar{varIndex}.m_varOrdering{1}(1)} = kron(observableOp, identity);
		else
			% If the variable belongs to the second party:
			cellObservable{cellVar{varIndex}.m_varOrdering{2}(1)} = kron(identity, observableOp);
		end	
	end

	% Obtain the optimal entangled state first
	% Initialize
	opState = zeros(sizeOp * sizeOp, 1);
	% Compute
	for col = 1 : sizeOp
		opState = opState + kron(identity(:, col), identity(:, col));
	end
	opState = (1 / sqrt(sizeOp)) * opState;
end