% The function: testCHSH(sdpLevel, genMonoCond, solverSpecify)
%
% Input parameters:
%	+ sdpLevel (optional): the level of the semidefinite program which we want the solver to run at.
%	+ genMonoCond (optional): a structure indicating how a list of monomials of length l = 1... sdpLevel should be generated.
%	+ solverSpecify (optional): a structure indicating information about the SDP solver that will be used.
% The function runs the quantum bound problem solver to approximate the bound of CHSH inequality and prints the results which comprise:
%		1) The bound value.
%		2) Extra information provided by underlying solvers (such as SeDuMi, YALMIP, etc.)
%
% Output parameters:
%	+ upperBoundVal: the upper bound value of the CHSH.
%	+ solverMessage
%	+ opMeasure: a cell of optimal observables.
%	+ opState: an optimal quantum state.
%
% Problem description:
%	+ Find an upper bound of:
%		P = <A_1 * B_1> + <A_1 * B_2> + <A_2 * B_1> - <A_2 * B_2>    
%	+ All variables are observables.
%	+ There are 2 partitions (parties) A = {A_1, A_2} and B = {B_1, B_2}
function [upperBoundVal solverMessage opMeasure opState] = testCHSH(varargin)
	sdpLevel = 1;
	hashGenMonoInfo = specifyGenListMonoCriteria();
	if nargin > 0
		sdpLevel = varargin{1};
	end
	if nargin > 1
		hashGenMonoInfo = varargin{2};
	end
	
	
	polyStr = 'A_1 * B_1 + A_1 * B_2 + A_2 * B_1 - A_2 * B_2';
	varPropWithName = {{'A_1', 'A_2'}, {'B_1', 'B_2'}};
	[polyOp ~] = createPolyFromExpr(polyStr, varPropWithName, 'observable');
	
	% Call the solver
	if nargin < 3
		[upperBoundVal solverMessage momentMatrix monoMapTable monoList] = findQuantumBound(polyOp, sdpLevel, hashGenMonoInfo);
	else
		[upperBoundVal solverMessage momentMatrix monoMapTable monoList] = findQuantumBound(polyOp, sdpLevel, hashGenMonoInfo, varargin{3});
	end

	[opMeasureCell opState] = getOptimalObservable(momentMatrix, polyOp, monoMapTable);

	% Print result
	disp('Upper bound value = ');
	disp(upperBoundVal);
	disp('Solver message = ');
	disp(solverMessage);
	
	cholDecompose = choleskyDecompose(momentMatrix, 1e-10);
	[result epsilon] = checkMomentDecompose(momentMatrix, cholDecompose);
	disp('Check Moment Decompose = ');
	disp(result);
	disp(epsilon);

	[result epsilon] = checkQuantumSol(opMeasureCell, opState, polyOp, upperBoundVal, momentMatrix, monoList);
	disp('Check Quantum Solution: ');
	disp(result);
	disp(epsilon);

	opMeasure = formatOutputMeasure(opMeasureCell, varPropWithName, 'observable');
end
	