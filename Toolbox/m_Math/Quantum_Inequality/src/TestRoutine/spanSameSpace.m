% The function: spanSameSpace(A, B, epsilon)
% 
% Inputs:
%	+ A, B: m x n matrices representing a set of column vectors.
%	+ epsilon: a positive real number. Any number x such that 0 < abs(x) < epsilon will be considered as 0.
%
% Output:
%	+ result = 1 if the column spaces of A and B are the same.
%	+ result = 0 otherwise.
%
% Methodology: The column spaces of A and B are the same if the reduced row-echelon form (excluding zero rows) of A and B
%				are the same!
function result = spanSameSpace(A, B, varargin)
	if nargin < 3
		epsilon = 1e-12;
	else
		epsilon = varargin{1};
		if epsilon < 0
			epsilon = -epsilon
		end
	end

	rrefA = toRREF(A, epsilon);
	rrefB = toRREF(B, epislon);

	rankA = computeRankRREF(A, epsilon);
	rankB = computeRankRREF(B, epsilon);

	if rankA ~= rankB
		result = 0;
	else
		for index = 1 : rankA
			if ~(norm(rrefA(index, :) - rrefB(index, :)) < epsilon)
				result = 0;
				return;
			end
		end

		result = 1;
	end
end