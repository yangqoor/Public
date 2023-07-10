% The function: toRREF(matrix, epsilon)
% 
% Inputs:
%	+ matrix: an m x n matrix.
%	+ epsilon: a positive real number. Any number x such that 0 < abs(x) < epsilon will be considered as 0.
%
% Output:
%	+ echelon: a reduced row-echelon form of matrix.
%
% Acknowledge: This function is based on the pseudocode presented in 
%								http://rosettacode.org/wiki/Reduced_row_echelon_form#MATLAB
function echelon = toRREF(matrix, varargin)
	if nargin < 2
		epsilon = 1e-12;
	else
		epsilon = varargin{1};
		if epsilon < 0
			epsilon = -epsilon;
		end
	end

	sizeMat = size(matrix);
	numCol = sizeMat(2);
	numRow = sizeMat(1);
	lead = 1;
	echelon = matrix;

	for row = 1 : numRow
		disp(row)
		if lead > numCol
			return;
		end

		% Find the row with maximum pivot entry
		maxChosen = row;
		flagStop = 0;
		while ~flagStop
			for curRow = row : numRow
				if abs(echelon(curRow, lead)) > abs(echelon(maxChosen, lead))
					maxChosen = curRow;
				end
			end

			if isZero(echelon(maxChosen, lead), epsilon)
				% All entries we consider so far are zero
				maxChosen = row;
				lead = lead + 1;
				if lead > numCol
					return;
				end
			else
				flagStop = 1;
			end
		end

		%while isZero(echelon(maxChosen, lead), epsilon)
		%	maxChosen = maxChosen + 1;
		%	if maxChosen > numRow
		%		maxChosen = row;
		%		lead = lead + 1;
		%		if lead > numCol
		%			return;
		%		end
		%	end
		%end
		disp(maxChosen)
		disp(lead)
		if maxChosen ~= row
			% Swap the two rows
			tempRow = echelon(row, :);
			echelon(row, :) = echelon(maxChosen, :);
			echelon(maxChosen, :) = tempRow;
		end
		disp(echelon)

		if ~isZero(echelon(row, lead), epsilon)
			echelon(row, :) = echelon(row, :) / echelon(row, lead);
		end

		for curRow = 1 : numRow
			if curRow ~= row
				echelon(curRow, :) = echelon(curRow, :) - echelon(curRow, lead) * echelon(row, :);
			end
		end
		disp(echelon)
		lead = lead + 1;
	end
end

function result = isZero(num, epsilon)
	result = abs(num) < epsilon;
end