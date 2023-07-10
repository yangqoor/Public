% The function: testI3322(sdpLevel, genListCriteria)
% Input parameter:
%	+ sdpLevel: the level of the semidefinite program which we want the solver to run at.
% If there is no input, we assume sdpLevel = 1
%
%	+ genListCriteria: a cell specifying how a list of monomials should be generated.
%
% The function runs the quantum bound problem solver to approximate the bound of I3322 and prints the results which comprise:
%		1) The bound value.
%		2) Extra information provided by underlying solvers (such as SeDuMi, YALMIP, etc.)
%
% Problem description:
%	+ Find an upper bound of:
%		P = A'a_1 * (B'b_1 + B'b_2 + B'b_3) + A'a_2 * (B'b_1 + B'b_2 - B'b_3) + A'a_3 * (B'b_1 - B'b_2)
%				- A'a_1 - 2 * B'b_1 - B'b_2
%	+ All variables are projectors.
%	+ There are two partitions (parties) A = {A'a_1, A'a_2, A'a_3} and B = {B'b_1, B'b_2, B'b_3}
function testI3322(varargin)
	if nargin == 0
		sdpLevel = 1;
		hashGenMonoInfo = {};
	else
		sdpLevel = varargin{1};
		hashGenMonoInfo = varargin{2};
	end
	
	% Declare the polynomial whose monomials are monoOne, ..., monoEleven
	% The information about the variables is represented as {{[1], [2], [3]}, {[4], [5], [6]}} which means:
	%		1) There are two partitions (Partition 1 contains variables who labels are 1, 2, 3. 
	%									 Partition 2 contains variables who labels are 4, 5, 6).
	%		   Note that a * b = b * a if a, b are in different partitions.
	%		2) In each parition, there are 3 input groups, each has only 1 element.
	% The variable type is PROJECTOR which is mapped to 0.
	expr = 'A"a_1 * (B"b_1 + B"b_2 + B"b_3) + A"a_2 * (B"b_1 + B"b_2 - B"b_3) + A"a_3 * (B"b_1 - B"b_2) - A"a_1 - 2 * B"b_1 - B"b_2';
	varPropWithName = {{{'A"a_1'}, {'A"a_2'}, {'A"a_3'}}, {{'B"b_1'}, {'B"b_2'}, {'B"b_3'}}};
	[polyOp ~] = createPolyFromExpr(expr, varPropWithName, 'projector', 'partial');
	
	% Call the solver
	[upperBoundVal solverMessage momentMatrix monoMapTable monoList] = findQuantumBound(polyOp, sdpLevel, hashGenMonoInfo);
	
	% Print result
	disp('Upper bound value = ');
	disp(upperBoundVal);
	disp('Solver message = ');
	disp(solverMessage);
	
	disp('Rank Loop Result: ');
	[rankLoop rankMoment epsilon] = hasRankLoop(momentMatrix, sdpLevel,  monoList, polyOp.m_varProperties);
	if(rankLoop)
		disp('Rank loop occurs')
	else
		disp('Rank loop does NOT occur');
	end
end
	