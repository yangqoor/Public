% The function: infixToPostfix(E)
%
% Input:
%	+ E: an infix expression. E can contain whitespaces, parentheses (i.e. '(' amd ')'), digits, operators (*, +, -, /, ^) and '.' (for real numbers), 
%								letters (for variable names)
%
% The function converts E into the corresponding postfix notation.
%
% Output:
%	+ postE: a cell representing the postfix expression of E. Each element in a cell is a number or variable names or operators (*, +, -, /).
%
% Assumption: 
%	+ The number of operators and parentheses in E is at most 5000
%	+ The number of terms and operators in E is at most 500
%
% Algorithm: Use a modified version of Shunting Yard Algorithm.
function cellPostExpr = infixToPostfix(expr)
	% Remove white spaces
	expr(expr == ' ') = '';

	% Initalize some variables
	opStack = char(zeros(1, 5000));
	lenStack = 0;

	lenExpr = length(expr);

	cellPostExpr = cell(1, 500);
	numEle = 0;

	term = char(zeros(1, 500));
	lenTerm = 0;

	isUnitary = 1;	% Default: True
	% Parsing
	for index = 1 : lenExpr
		character = expr(index);

		if (character == '+') || (character == '-') || (character == '*') || (character == '/') || (character == '^')
			if (character == '-' || character == '+') && isUnitary
				lenTerm = lenTerm + 1;
				term(lenTerm) = character;

			elseif isUnitary
				error('Only + and - can be unitary operators');
			else
				% Process term
				if lenTerm
					numEle = numEle + 1;
					cellPostExpr{numEle} = processTerm(term(1 : lenTerm));
					lenTerm = 0;
				end
				
				while lenStack > 0 && opStack(lenStack) ~= '(' && assignPrecedence(opStack(lenStack)) >= assignPrecedence(character)
					% Pop
					numEle = numEle + 1;
					cellPostExpr{numEle} = opStack(lenStack);
					lenStack = lenStack - 1;
				end

				% Push
				lenStack = lenStack + 1;
				opStack(lenStack) = character;
			end

		elseif character == '('
			% Push
			lenStack = lenStack + 1;
			opStack(lenStack) = character;

			isUnitary = 1;

		elseif character == ')'
			% Process term
			if lenTerm
				numEle = numEle + 1;
				cellPostExpr{numEle} = processTerm(term(1 : lenTerm));
				lenTerm = 0;
			end
			% Pop until finding the left parenthesis
			while lenStack > 0 && opStack(lenStack) ~= '('
				numEle = numEle + 1;
				cellPostExpr{numEle} = opStack(lenStack);
				lenStack = lenStack - 1;
			end

			if lenStack == 0
				% Mismatch
				error('The expression is not parenthesis balanced. A left parenthesis is missing');
			end

			% Otherwise pop '('
			lenStack = lenStack - 1;

			isUnitary = 0;
		else
			lenTerm = lenTerm + 1;
			term(lenTerm) = character;

			isUnitary = 0;
		end
	end

	if lenTerm
		numEle = numEle + 1;
		cellPostExpr{numEle} = processTerm(term(1 : lenTerm));
	end

	% Pop all operators left in the stack
	while lenStack > 0
		if opStack(lenStack) == '('
			% Mismatch
			error('The expression is not parenthesis balanced. A right parenthesis is missing');
		end

		numEle = numEle + 1;
		cellPostExpr{numEle} = opStack(lenStack);
		lenStack = lenStack - 1;
	end

	cellPostExpr = cellPostExpr(1 : numEle);
end 

% The following are some helper functions for infixToPostfix function!
function precedence = assignPrecedence(operator)
	switch operator
		case '+'
			precedence = 0;
		case '-'
			precedence = 0;
		case '*'
			precedence = 1;
		case '/'
			precedence = 1;
		otherwise
			% The case the operator is '^'
			precedence = 2;
	end
end

function resultTerm = processTerm(term)
	% Try if it is a number
	[termValue, status] = str2num(term);

	if ~status
		% It is not a number. So it is a variable name
		resultTerm = term;
	else
		resultTerm = termValue;
	end
end