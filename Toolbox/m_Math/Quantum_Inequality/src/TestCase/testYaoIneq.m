% The function: testYaoIneq(sdpLevel)
% Input parameter:
%	+ sdpLevel: the level of the semidefinite program which we want the solver to run at.
% If there is no input, we assume sdpLevel = 2
%
%	+ genListCriteria: a cell specifying how a list of monomials should be generated.
%
% The function runs the quantum bound problem solver to approximate the bound of Yao's inequality and prints the results which comprise:
%		1) The bound value.
%		2) Extra information provided by underlying solvers (such as SeDuMi, YALMIP, etc.)
%
% Problem description:
%	+ Find an upper bound of:
%		P = <A_1 * B_2 * C_3> + <A_2 * B_3 * C_1> + <A_3 * B_1 * C_2> - <A_1 * B_3 * C_2> - <A_2 * B_1 * C_3> - <A_3 * B_2 * C_1>     
%	+ All variables are observables.
%	+ There are 3 partitions (parties) A = {A_1, A_2, A_3} and B = {B_1, B_2, B_3} and C = {C_1, C_2, C_3}
function testYaoIneq(varargin)
	if nargin == 0
		sdpLevel = 2;
		hashGenMonoInfo = {};
	else
		sdpLevel = varargin{1};
		hashGenMonoInfo = varargin{2};
	end
	
	
	polyStr = 'A_1 * B_2 * C_3 + A_2 * B_3 * C_1 + A_3 * B_1 * C_2 - A_1 * B_3 * C_2 - A_2 * B_1 * C_3 - A_3 * B_2 * C_1';
	varPropWithName = {{'A_1', 'A_2', 'A_3'}, {'B_1', 'B_2', 'B_3'}, {'C_1', 'C_2', 'C_3'}};
	[polyOp ~] = createPolyFromExpr(polyStr, varPropWithName, 'observable');
	
	% Call the solver
	result = findQuantumBound(polyOp, sdpLevel, checkIdentityConstraint, hashGenMonoInfo);
	
	% Print result
	disp('Upper bound value = ');
	disp(result(1));
	disp('Solver message = ');
	disp(result(2));
	
end
	