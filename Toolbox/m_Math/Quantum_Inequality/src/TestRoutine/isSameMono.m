% The function: isSameMono(monoOne, monoTwo)
%
% Inputs:
%	+ monoOne, monoTwo: monomial structures.
%
% Output:
%	+ result = 1 if monoOne is the same as monoTwo.
%	+ result = 0 otherwise.
function result = isSameMono(monoOne, monoTwo)
	compareResult = compareMono(monoOne, monoTwo)

	if ~compareResult
		result = 1;
	else
		result = 0;
	end
end