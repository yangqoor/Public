% The function: evaluatePolyExpr(E, polyVarHash)
%
% The function evaluates a postfix polynomial expression and returns the result polynomial.
%
% Input:
%	+ E: a cell representing an arithmetic expression in postfix form.
%	+ polyVarHash: a hash table that maps a string representing a variable name to its corresponding polynomial structure (or object)
%
% Output:
%	+ polyObject: a polynomial object built from the input expression.
function polyObject = evaluatePolyExpr(exprPost, polyVarHash)
	numEle = length(exprPost);

	cellTermStack = cell(1, 5000);
	numTerm = 0;

	for index = 1 : numEle
		curTerm = exprPost{index};

		if ischar(curTerm) && length(curTerm) == 1 && (curTerm == '+' || curTerm == '*' || curTerm == '-' || curTerm == '/' || curTerm == '^')
			% curTerm is an operator.
			% Pop the top two elements in the stack
			if numTerm < 2
				error('Operators should be binary!');
			end

			termTwo = cellTermStack{numTerm};
			numTerm = numTerm - 1;
			termOne = cellTermStack{numTerm};
			numTerm = numTerm - 1;

			if isstruct(termOne) && isstruct(termOne)
				% Both terms are polynomial
				if curTerm == '/' || curTerm == '^'
					error('Division and exponentiation are not applicable to polynomials at the moment!');
				elseif curTerm == '*'
					opResult = mulPoly(termOne, termTwo);
				elseif curTerm == '+'
					opResult = addPoly(termOne, termTwo);
				else
					% curTerm should be '-'
					negate = scalarMulPoly(termTwo, -1);
					opResult = addPoly(termOne, negate);
				end
			elseif isnumeric(termOne) && isnumeric(termTwo)
				% Both terms are numeric
				switch curTerm
					case '*'
						opResult = termOne * termTwo;
					case '+'
						opResult = termOne + termTwo;
					case '-'
						opResult = termOne - termTwo;
					case '/'
						opResult = termOne / termTwo;
					otherwise
						% curTerm = '^'
						opResult = termOne ^ termTwo;
				end
			else
			 	% One is polynomial and the other is numerical.
			 	% Operators allowed in this case are '*' and '/' only.
			 	if curTerm == '*' || curTerm == '/'
			 		if isnumeric(termOne)
			 			number = termOne;
			 			polynomial = termTwo;
			 		else
			 			number = termTwo;
			 			polynomial = termOne;
			 		end

			 		if curTerm == '*'
			 			opResult = scalarMulPoly(polynomial, number);
			 		else
			 			opResult = scalarMulPoly(polynomial, 1 / number);
			 		end
			 	else
			 		error('+, -, ^ are not applicable to a number and a polynomial!');
			 	end 
			end

			% Push the result to the stack
			numTerm = numTerm + 1;
			cellTermStack{numTerm} = opResult;
		else
			%curTerm is not an operator. Push it to the stack
			numTerm = numTerm + 1;

			if ischar(curTerm)
				% curTerm is a variable name. Push the corresponding polynomial into the stack
				if ~polyVarHash.isKey(curTerm)
					error(sprintf('%s is not a variable name. Otherwise, you should specify it in the cell of variable names', curTerm));
				end

				cellTermStack{numTerm} = polyVarHash(curTerm);
			else
				% curTerm is a real number
				cellTermStack{numTerm} = curTerm;
			end
		end
	end

	% The final result is on top of the stack
	polyObject = cellTermStack{numTerm};
end