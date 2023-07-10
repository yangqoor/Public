% The function: findMono(cellMono, mono)
%
% Inputs:
%	+ cellMono: a cell of monomial structures.
%	+ mono: a monomial structures
%
% Outputs:
%	+ indexVector: a vector containning the indices of instances of mono in cellMono.
function indexVector = findMono(cellMono, mono)
	indexVector = [];

	numMono = length(cellMono);
	for index = 1 : numMono
		if isSameMono(mono, cellMono{index})
			indexVector(end + 1) = index;
		end
	end
end