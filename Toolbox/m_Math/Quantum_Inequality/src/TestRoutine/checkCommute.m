% The function: checkCommute(S, T)
% 
% Inputs:
%	+ S, T: cells of square matrices of the same size.
%
% Outputs:
%	+ result = 1 if for any matrix A in S, for any matrix B in T, we have AB = BA
%	+ result = 0 otherwise
%	+ epsilon: (In case result = 1) a positive real number. Any number x such that -epsilon < x < epsilon will be considered as 0. It is 
%				the tolerance for which commutativity occurs.
function [result epsilon]= checkCommute(cellOne, cellTwo)
	epsilon = 1e-12;

	numOne = length(cellOne);
	numTwo = length(cellTwo);
	while epsilon < 1e-5
		result = 1;
		for indexOne = 1 : numOne
			for indexTwo = 1 : numTwo
				commutator = cellOne{indexOne} * cellTwo{indexTwo} - cellTwo{indexTwo} * cellOne{indexOne};

				if ~isZeroMatrix(commutator, epsilon)
					result = 0;
					break;
				end
			end

			if ~result
				break;
			end
		end

		if result
			return;
		end

		epsilon = epsilon * 10;
	end

	% At this point, result = 0
	result = 0;
end