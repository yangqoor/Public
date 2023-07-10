% The function: removeDup(A, mode)
% It removes duplicates in an array A in a manner specified by mode.
% If A[i] == A[i - 1] and mode == 0, then it removes A[i - 1]. The function repeats the process with the resulting array.
% If A[i] == A[i - 1] and mode == 1, then it removes A[i] and A[i - 1]. The function repeats the process with the resulting array.
% Example:
% 	1) removeDup([1 2 3 3], 1) = [1 2]
%   2) removeDup([1 2 3 3], 0) = [1 2 3]
%   3) removeDup([1 2 3 3 2 1], 1) = []
%   4) removeDup([1 2 3 3 2 1], 0) = [1 2 3 2 1]
%   5) removeDup([1 1 1 1 2], 0) = [1 2]
%	6) removeDup([1 1 1 1 2], 1) = [2]
% Assumption: inputs are in the correct format. The array A is not null.
% The function returns a cell of size 1 x 2. The first element is the array after removing duplicates. The second element is its length.
function [newArr, newLen] = removeDup(A, mode)
	i = 2;
	len = length(A);
	while i <= len
		if A(i) == A(i - 1)
			if mode
				% Case: mode == 1
				A(i - 1 : i) = [];
				len = len - 2;
				i = max(1, i - 2);
			else
				% Case: mode == 0
				A(i - 1) = [];
				len = len - 1;
				i = max(1, i -1);
			end
		end
		i = i + 1;
	end
	newArr = A;
	newLen = len;
end