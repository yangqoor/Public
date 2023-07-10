% The function: testModThreeGame()
% Input parameters:
%	+ sdpLevel (optional): the level of the semidefinite program which we want the solver to run at.
%	+ genMonoCond (optional): a structure indicating how a list of monomials of length l = 1... sdpLevel should be generated.
%	+ solverSpecify (optional): a structure indicating information about the SDP solver that will be used.
%
% The function runs the quantum bound problem solver to approximate the bound of the inequality of the mod-3 game and prints the results which comprise:
%		1) The bound value.
%		2) Extra information provided by underlying solvers (such as SeDuMi, YALMIP, etc.)
%
% Problem description:
%	+ Find an upper bound of:
%		P = <1/4 * (As0a0 * (Bt0b0 + Bt1b0)
%				  + As0a1 * (Bt0b2 + Bt1b2)
%				  + As0a2 * (Bt0b1 + Bt1b1)
%				  + As1a0 * (Bt0b0 + Bt1b1)
%				  + As1a1 * (Bt0b2 + Bt1b0)
%				  + As1a2 * (Bt0b1 + Bt1b2))>    
%	+ All variables are projectors.
%	+ There are 2 partitions (parties) 
%				A = {{As0a0, As0a1, As0a2}, {As1a0, As1a1, As1a2}} and 
%				B = {{Bt0b0, Bt0b1, Bt0b2}, {Bt1b0, Bt1b1, Bt1b2}}
function [output optimal] = testModThreeGameSimplified(varargin)
	sdpLevel = 1;
	hashGenMonoInfo = specifyGenListMonoCriteria();
	if nargin > 0
		sdpLevel = varargin{1};
	end
	if nargin > 1
		hashGenMonoInfo = varargin{2};
	end

	polyStr = '1/4 * (As0a0 * (Bt0b0 + Bt1b0) + As0a1 * (Bt0b2 + Bt1b2) + As0a2 * (Bt0b1 + Bt1b1) + As1a0 * (Bt0b0 + Bt1b1) + As1a1 * (Bt0b2 + Bt1b0) + As1a2 * (Bt0b1 + Bt1b2))';
	varPropWithName = {{{'As0a0', 'As0a1', 'As0a2'}, {'As1a0', 'As1a1', 'As1a2'}}, {{'Bt0b0', 'Bt0b1', 'Bt0b2'}, {'Bt1b0', 'Bt1b1', 'Bt1b2'}}};
	[polyOp reduceVar] = createPolyFromExpr(polyStr, varPropWithName, 'projector', 'full');

	% Call the solver
	% Call the solver
	if nargin < 3
		[upperBoundVal solverMessage momentMatrix monoMapTable monoList] = findQuantumBound(polyOp, sdpLevel, hashGenMonoInfo);
	else
		[upperBoundVal solverMessage momentMatrix monoMapTable monoList] = findQuantumBound(polyOp, sdpLevel, hashGenMonoInfo, varargin{3});
	end
	result = {upperBoundVal, solverMessage, momentMatrix, monoMapTable, monoList};
	% Print result
	disp('Upper bound value = ');
	disp(result{1});
	disp('Solver message = ');
	disp(result{2});

	% Check if there is a rank loop
	rankLoopResult = hasRankLoop(momentMatrix, sdpLevel, monoList, polyOp.m_varProperties);
	[opMeasure opState] = getOptimalProjector(result{3}, sdpLevel, result{5}, polyOp.m_varProperties);
	cholDecompose = choleskyDecompose(result{3}, 1e-10);
	if rankLoopResult
		disp('Rank loop occurs');
	else
		disp('Rank loop does NOT occur');
	end
		disp(evaluatePolynomial(polyOp, opMeasure, opState));
	disp('Check Moment Var Value: ');
	[checkResult epsilon] = checkMomentVarValue(result{3}, polyOp, result{5}, opMeasure, opState);
	disp(checkResult);
	disp(epsilon);
	

	output = result;
	optimal = opMeasure;

	
	disp('Check Moment Decompose: ');
	[checkResult epsilon] = checkMomentDecompose(result{3}, cholDecompose);

	disp(checkResult);
	disp(epsilon);
end