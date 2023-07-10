% The function: generateClifford(M)
%
% Input:
%	+ M: an integer indicating the number of matrices in the Clifford algebra.
%
% Output:
%	+ cellClifford: a cell of M matrices representing the Clifford Algebra.
%
% Methodology:
%	+ Let N = floor(M / 2)
%	+ Let X = (0 1; 1 0) be the Pauli-X matrix.
%	  Let Y = (0 -i; i 0) be the Pauli-Y matrix.
%	  Let Z = (1 0; 0 -1) be the Pauli-Z matrix.
%
%   + Let C(1), C(2), ..., C(M) be the matrices in the Clifford Algebra. Note that C(i) is of order 2^N
%	+ For j = 1 to N we have
%		C(2j - 1) = Y x Y ... x Y (j - 1 times) x X x (I x I x ... x I) (n - j times) where I is the 2 x 2 identity matrix and
%			A x B is the Kronecker tensor product of A and B
%		C(2j) = Y x Y ... x Y (j - 1 times) x Z x (I x I x ... x I) (n - j) times
%	+ If M is odd, then
%		C(M) = iC(1)C(2)...C(2n)
%
%	+ Note that I x I ... x I (k times) = U where U is the 2^k x 2^k identity matrix!
%
% Time complexity: O(2^())
function cellClifford = generateClifford(M)
	N = floor(M / 2);

	% Pre-allocate
	cellClifford = cell(1, N);

	% Define Pauli matrices
	pauliX = [0 1; 1 0];
	pauliY = [0 -i; i 0];
	pauliZ = [1 0; 0 -1];

	% Note that C(1) = X x (I x I x ... x I) (n - 1 times)
	%		and C(2) = Z x (I x I x ... x I) (n - 1 times)
	bigIdentity = eye(2 ^ (N - 1));
	cellClifford{1} = kron(pauliX, bigIdentity);
	cellClifford{2} = kron(pauliZ, bigIdentity);

	tensorProductY = pauliY;
	for j = 2 : N
		identity = eye(2 ^ (N - j));
		cellClifford{2 * j - 1} = kron(kron(tensorProductY, pauliX), identity);
		cellClifford{2 * j} = kron(kron(tensorProductY, pauliZ), identity);

		% Prepare for the next loop
		tensorProductY = kron(tensorProductY, pauliY);
	end

	% In case M is odd
	if mod(M, 2)
		% Intialize product to an 2^N x 2^N identity matrix!
		product = eye(2 ^ N);

		for j = 1 : 2 * N
			product = product * cellClifford{j};
		end

		cellClifford{M} = i * product;
	end
end