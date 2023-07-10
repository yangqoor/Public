% The function: testMod2Game(sdpLevel)
% Input parameters:
%	+ sdpLevel (optional): the level of the semidefinite program which we want the solver to run at.
%	+ genMonoCond (optional): a structure indicating how a list of monomials of length l = 1... sdpLevel should be generated.
%	+ solverSpecify (optional): a structure indicating information about the SDP solver that will be used.
%
% The function runs the quantum bound problem solver to approximate the bound of the inequality of the mod-2 game and prints the results which comprise:
%		1) The bound value.
%		2) Extra information provided by underlying solvers (such as SeDuMi, YALMIP, etc.)
%
% Problem description:
%	+ Find an upper bound of:
%		P = 1/4 * (<A1_0 * B1_0> + <A0_0 * B0_0> + <A0_0 * B0_1> + <A1_0 * B1_1> +
%				   <A0_1 * B0_0> + <A0_1 * B1_1> + <A1_1 * B0_1> + <A1_1 * B1_0>)    
%	+ All variables are projectors.
%	+ There are 2 partitions (parties) A = {{A0_0, A1_0}, {A1_0, A1_1}} and B = {{B0_0, B0_1}, {B1_0, B1_1}}
function [valResult opResult] = testMod2Game(varargin)
	sdpLevel = 1;
	hashGenMonoInfo = specifyGenListMonoCriteria();
	if nargin > 0
		sdpLevel = varargin{1};
	end
	if nargin > 1
		hashGenMonoInfo = varargin{2};
	end
	
	polyStr = '1/4 * (A1_0 * B1_0 + A0_0 * B0_0 + A0_0 * B0_1 + A1_0 * B1_1 + A0_1 * B0_0 + A0_1 * B1_1 + A1_1 * B0_1 + A1_1 * B1_0)';
	varPropWithName = {{{'A0_0', 'A1_0'}, {'A0_1', 'A1_1'}}, {{'B0_0', 'B1_0'}, {'B0_1', 'B1_1'}}};
	[polyOp reduceVar] = createPolyFromExpr(polyStr, varPropWithName, 'projector', 'full');
	
	% Call the solver
	[upperBoundVal solverMessage momentMatrix monoMapTable monoList]  = findQuantumBound(polyOp, sdpLevel, hashGenMonoInfo);
	valResult = {upperBoundVal, solverMessage, momentMatrix, monoMapTable, monoList};
	result = {upperBoundVal, solverMessage, momentMatrix, monoMapTable, monoList};
	% Print result
	%disp('Upper bound value = ');
	%disp(result{1});
	%disp('Solver message = ');
	%disp(result{2});
	
	disp('Rank Loop Result = ')
	epsilon = 1e-12;
	result{3} = standardizeMatrix(result{3}, 1e-10);
	[rankLoop rankMoment epsilon] = hasRankLoop(result{3}, sdpLevel, result{5}, polyOp.m_varProperties);
	
	if rankLoop
		disp('Rank loop occurs');
		disp('The threshold epsilon = ');
		disp(epsilon);

		opResult = getOptimalProjector(result{3}, sdpLevel, result{5}, polyOp.m_varProperties);
	else
		disp('Rank loop does not occur');
		disp(epsilon);
	end

	cholDecompose = choleskyDecompose(result{3}, 1e-7);
	eig(cholDecompose)
	rref(cholDecompose, 1e-10)
	%cholDecompose = standardizeMatrix(cholDecompose, 1e-6);
	%cholDecompose = standardizeMatrix(cholDecompose, 1e-3);
	%diagonal = diag(cholDecompose)

	%rankMoment = rankHermitian(result{3}, 1e-8)
	%rankChol = rankHermitian(cholDecompose, 1e-8)
	%deter = det(cholDecompose)
	numMono = length(result{5});

	firstMono = NonCommuteMonomial({[], [3]}, 1);
	for index = 1 : numMono
		product = mulMonomial(firstMono, result{5}{index}, polyOp.m_varType, polyOp.m_inputGroup);

		monoVarOrder = result{5}{index}.m_varOrdering
		productVarOrder = product.m_varOrdering

		if product.m_degree >= 0 && product.m_degree <= sdpLevel
			orderStr = getMonoVarOrderStr(result{5}{index});
			coord = result{4}(orderStr);

			if coord(1) ~= 1
				error('Something wrong with findQuantumBound')
			end

			column = coord(2);

			orderStrP = getMonoVarOrderStr(product);
			coordP = result{4}(orderStr);
			if coordP(1) ~= 1
				error('Something wrong with findQuantumBound')
			end

			columnP = coordP(2);

			LHS = opResult{3} * cholDecompose(:, column);
			RHS = cholDecompose(:, columnP);

			differ = LHS - RHS;
			disp('Difference = ')
			differ = standardizeMatrix(differ, 1e-10)
		elseif product.m_degree < 0
			orderStr = getMonoVarOrderStr(result{5}{index});
			coord = result{4}(orderStr);

			if coord(1) ~= 1
				error('Something wrong with findQuantumBound')
			end

			column = coord(2);

			LHS = opResult{3} * cholDecompose(:, column);

			disp('Expect zero = ')
			LHS = standardizeMatrix(LHS, 1e-10)
		end
	end

	numVarPlusOne = length(opResult);
	disp(evaluatePolynomial(polyOp, opResult(1 : (numVarPlusOne - 1)), opResult{numVarPlusOne}));
	disp('Check Moment Var Value: ');
	epsilon = 1e-10;
	checkResult = 0;
	while ~checkResult && epsilon < 10e-4
		checkResult = checkMomentVarValue(result{3}, polyOp, result{5}, opResult(1 : (numVarPlusOne - 1)), opResult{numVarPlusOne}, epsilon);
		
		if checkResult
			break;
		end

		epsilon = epsilon * 10;
	end
	disp(checkResult);
	disp(epsilon);
	disp('Check Moment Decompose: ');
	epsilon = 1e-10;
	checkResult = 0;
	while ~checkResult && epsilon < 10e-4
		checkResult = checkMomentDecompose(result{3}, cholDecompose, epsilon);
		
		if checkResult
			break;
		end

		epsilon = epsilon * 10;
	end

	disp(checkResult);
	disp(epsilon);
end
