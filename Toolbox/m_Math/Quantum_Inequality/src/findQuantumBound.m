% The function: findQuantumBound(inputPoly, sdpOrder, hashGenMonoInfo, solverSpecify)
% Parameters:
%	1) inputPoly: a NonCommutePolynomial object. Our objective is to find a bound 
%            for this polynomial. Also, inputPoly contains all information about
%			 the measurement variables.
%	2) sdpOrder: the level of the SDP hierachy.
%	3) hashGenMonoInfo (optional): a hash map that specifies how monomials in each order should be generated. This variable is a result of the
%										function specifyGenListMonoCriteria.
%	4) solverSpecify (optional): a YALMIP structure that specifies the SDP solver, precision and other information.
%
% Note that there is no need to check the identity constraint with the modified algorithm.
%
% Calculates the upperbound of inputPoly.
%
% The function returns [upperBoundVal, solverMessage, momentMatrix, monoMapTable, monoList] where 
%	+ upperBoundVal: the upperbound of inputPoly calculated by our program.
%	+ solverMessage: the result returned from YALMIP and SeDuMi functions.
%	+ momentMatrix: the moment matrix
%	+ monoMaptable: the hash table that maps to string representation of a monomial to the coordinate of that monomial in the moment matrix.
%				It will be used for extracting the optimal measurement operators later!
%	+ monoList: a list of monomials generated in Step 1 and is used to index the moment matrix! (This is for computing rank loop later!)
function [upperBoundVal solverMessage momentMatrix monoMapTable monoList] = findQuantumBound(inputPoly, sdpOrder, varargin)
	% Default values!
	hashGenMonoInfo = specifyGenListMonoCriteria();
	solverSpecify = sdpsettings('solver','sedumi','sedumi.eps',1e-12);
	if nargin >= 3
		hashGenMonoInfo = varargin{1};
	end
	if nargin >= 4
		solverSpecify = varargin{2};
	end

	% Check errors
	if sdpOrder * 2 < inputPoly.m_degree
		error('The polynomial degree must be larger than or equal to two times the SDP order');
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Start Step 1. (Generate monomials)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	str = sprintf('STEP 1: Generate a list of monomials with specify constraints');
	disp(str);
	
	% Find the list of monomials
	% monoList{1} is always the identity.
	% Note that we take into account the projector / observable constraint to reduce the number of monomials generated!
	monoList = generateCellMonomial(sdpOrder, inputPoly.m_varProperties, inputPoly.m_varType, hashGenMonoInfo);
	lenMonoList = length(monoList);
	str = sprintf('There are %d monomials generated', lenMonoList);
	disp(str);
	disp('End Step 1');
	
	%MAX_FAST = 80;
	%if lenMonoList > MAX_FAST
	%	str = sprintf('It may take very long time to run an SDP with %d monomials', lenMonoList);
	%	disp(str);
	%	strResp = input('Would you like to continue? ["y" for YES and "n" for NO]');
	%	if ~(strResp == 'y' || strResp == 'Y' || lower(strResp) == 'yes')
	%		return;
	%	end
	%end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Start Step 2. (Establish constraints between elements in the monoment matrix (excluding identity constraints))
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	disp('STEP 2: Establish constraints between elements in the monoment matrix (excluding identity constraints)');
	
	% Deal with the following constraints
	% 3) moment(1, n) == moment(n, 1) for 2 <= n <= lenMonoList (since I * A = A * I for all measurements A)
	% 4) Commutativity constraint
	% 5) Orthogonality constraint (Only applicable to projector variables)
	% 6) Projector / Observable constraint.
	% Note that all these constraints are considered in the multiplication of monomials. Therefore, we only need to examine
	% 	the result of monomial multiplication.
	
	% Declare a hash table. It maps to string representation of a monomial to the coordinate of that monomial in the moment matrix
	% The moment matrix will be declared later. We know that the moment matrix is of size lenMonoList x lenMonoList
	monoMapTable = containers.Map();
	
	% These variables are used to vectorize the task of establishing constraints, hence to speed up the code.
	leftSideConstraint = zeros(1, lenMonoList * lenMonoList);
	rightSideConstraint = zeros(1, lenMonoList * lenMonoList);
	numStepTwoConstraint = 0;
	zeroConstraint = zeros(1, lenMonoList * lenMonoList);
	numZeroConstraint = 0;
	
	polyVarType = inputPoly.m_varType;
	polyInputGroup = inputPoly.m_inputGroup;
	for row = 1 : lenMonoList
		% Print how many entries has been processed.
		if row == floor(lenMonoList / 4)
			disp('1/4 of the moment matrix has been processed');
		end
		if row == floor(lenMonoList / 2)
			disp('1/2 of the moment matrix has been processed');
		end
		if row == floor(3 * lenMonoList / 4)
			disp('3/4 of the moment matrix has been processed');
		end
		
		adjoint = getAdjoint(monoList{row});
		for col = 1 : lenMonoList
			% Multiply the ADJOINT (complex conjugate transpose) of monoList{row} and monoList{col}
			% We do consider constraint types (3), (4), (5), (6) in monomial multiplication
			mulResult = mulMonomial(adjoint, monoList{col}, polyVarType, polyInputGroup);
			keyStr = getMonoVarOrderStr(mulResult);
			
			if monoMapTable.isKey(keyStr)
				% It means the monomial has appeared and been added to the hash table before. Hence, we find a new equality constraint.
				coordinate = monoMapTable(keyStr);
				% constraint = [constraint, moment(row, col) == moment(coordinate(1), coordinate(2))];
				numStepTwoConstraint = numStepTwoConstraint + 1;
				leftSideConstraint(numStepTwoConstraint) = row + lenMonoList * (col - 1);
				rightSideConstraint(numStepTwoConstraint) = coordinate(1) + lenMonoList * (coordinate(2) - 1);
				
			elseif isempty(keyStr)
				% keyStr is empty. That means mulResult is a zero monomial. Hence moment(row, col) = 0
				% constraint = [constraint, moment(row, col) == 0];
				numZeroConstraint = numZeroConstraint + 1;
				zeroConstraint(numZeroConstraint) = row + lenMonoList * (col - 1);
			else
				% This monomial appears for the first time. We add its coordinate in the moment matrix to the hash table.
				monoMapTable(keyStr) = [row col];
			end
		end
	end
	disp('4/4 of the moment matrix has been processed');
	disp('End Step 2');
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Start Step 3. (Declare the moment matrix and constraint)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    disp('STEP 3: Declaring the moment matrix and setting up some constraints');
	% Declare the moment matrix.
	disp('Declaring Moment Matrix (YALMIP Part): ');
	moment = sdpvar(lenMonoList, lenMonoList, 'hermitian', 'complex');
	disp('Done!');
	
	% Declare and initialize the constraint
	% 1) moment >= 0 (The moment matrix must be positive semi-definite)
	% 2) moment(1, 1) == 1 (<x | I * I | x> = <x|x> = 1)
	% 3) constraints established in Step 2
	disp('Declaring Constraint List and adding constraints (YALMIP part): ');

	if numStepTwoConstraint > 0
		constraint = [moment >= 0, moment(1, 1) == 1, moment(leftSideConstraint(1 : numStepTwoConstraint)) - moment(rightSideConstraint(1 : numStepTwoConstraint)) == 0];
	end
	if numZeroConstraint > 0	
		constraint = [constraint, moment(zeroConstraint(1 : numZeroConstraint)) == 0];
	end

	if ~polyVarType
		% In case of projectors, the sum of all singleton monomials in each input group must be 'less than or equal to' the identity.
		numPartition = length(inputPoly.m_varProperties);
		sumInputGroupConstraint = [];
		for partitionNo = 1 : numPartition
			numInputGroup = length(inputPoly.m_varProperties{partitionNo});
			
			for groupNo = 1 : numInputGroup
				numVarPerGroup = length(inputPoly.m_varProperties{partitionNo}{groupNo});
				mySum = 0;

				for varNoIndex = 1 : numVarPerGroup
					varNo = inputPoly.m_varProperties{partitionNo}{groupNo}(varNoIndex);
					singleton = createSingleton(varNo, partitionNo, numPartition);
					strSingle = getMonoVarOrderStr(singleton);
					coord = monoMapTable(strSingle);
					mySum = mySum + moment(coord(1), coord(2));
				end

				sumInputGroupConstraint = [sumInputGroupConstraint, mySum <= 1];
			end

			
		end

		constraint = [constraint, sumInputGroupConstraint];
	end

	disp('Done!');
	disp('End Step 3');

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Start Step 3. (Declaring objective variable (to optimize)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Dealing with constraint are FINISHED!
	% Now prepare for the objective, i.e. the value we want to optimize
	disp('STEP 4: Declaring objective variable (YALMIP Part)');
	objective = 0;
	for monoNo = 1 : length(inputPoly.m_cellMonomial)
		keyStr = getMonoVarOrderStr(inputPoly.m_cellMonomial{monoNo});
		if ~monoMapTable.isKey(keyStr)
			error('Your input contains Invalid monomials');
		end
		coordinate = monoMapTable(keyStr);
		objective = objective + inputPoly.m_cellMonomial{monoNo}.m_coeff * moment(coordinate(1), coordinate(2));
	end
	disp('Done!');
	disp('End Step 4');

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Final Step: Solving the SDP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	disp('STEP 5:Using SeDuMi to solve the SDP (YALMIP and SeDuMi Part)');
	% Solve SDP.
	% We want to maximize objective. By default, YALMIP finds the minimum value. Hence, we must pass -objective into the function
	solverMessage = solvesdp(constraint, -objective, solverSpecify);
	
	complexNum = double(objective);
	upperBoundVal = real(complexNum);
	momentMatrix = double(moment);

	%objectiveVal = 'Test';
	%complexNum = 'Test';
	%resultSolver = 'Test';
end