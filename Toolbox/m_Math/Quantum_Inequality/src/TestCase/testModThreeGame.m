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
%		P = <1/9 * (As0a0 * (Bt0b0 + Bt1b0 + Bt2b0)
%				  + As0a1 * (Bt0b2 + Bt1b2 + Bt2b2)
%				  + As0a2 * (Bt0b1 + Bt1b1 + Bt2b1)
%				  + As1a0 * (Bt0b0 + Bt1b1 + Bt2b2)
%				  + As1a1 * (Bt0b2 + Bt1b0 + Bt2b1)
%				  + As1a2 * (Bt0b1 + Bt1b2 + Bt2b0)
%				  + As2a0 * (Bt0b0 + Bt1b2 + Bt2b1)
%				  + As2a1 * (Bt0b2 + Bt1b1 + Bt2b0)
%				  + As2a2 * (Bt0b1 + Bt1b0 + Bt2b2))>    
%	+ All variables are projectors.
%	+ There are 2 partitions (parties) 
%				A = {{As0a0, As0a1, As0a2}, {As1a0, As1a1, As1a2}, {As2a0, As2a1, As2a2}} and 
%				B = {{Bt0b0, Bt0b1, Bt0b2}, {Bt1b0, Bt1b1, Bt1b2}, {Bt2b0, Bt2b1, Bt2b2}}
function testModThreeGame(varargin)
	sdpLevel = 1;
	hashGenMonoInfo = specifyGenListMonoCriteria();
	if nargin > 0
		sdpLevel = varargin{1};
	end
	if nargin > 1
		hashGenMonoInfo = varargin{2};
	end

	polyStr = '1/9 * (As0a0 * (Bt0b0 + Bt1b0 + Bt2b0) + As0a1 * (Bt0b2 + Bt1b2 + Bt2b2) + As0a2 * (Bt0b1 + Bt1b1 + Bt2b1) + As1a0 * (Bt0b0 + Bt1b1 + Bt2b2) + As1a1 * (Bt0b2 + Bt1b0 + Bt2b1) + As1a2 * (Bt0b1 + Bt1b2 + Bt2b0) + As2a0 * (Bt0b0 + Bt1b2 + Bt2b1) + As2a1 * (Bt0b2 + Bt1b1 + Bt2b0) + As2a2 * (Bt0b1 + Bt1b0 + Bt2b2))';
	varPropWithName = {{{'As0a0', 'As0a1', 'As0a2'}, {'As1a0', 'As1a1', 'As1a2'}, {'As2a0', 'As2a1', 'As2a2'}}, {{'Bt0b0', 'Bt0b1', 'Bt0b2'}, {'Bt1b0', 'Bt1b1', 'Bt1b2'}, {'Bt2b0', 'Bt2b1', 'Bt2b2'}}};
	[polyOp reduceVar] = createPolyFromExpr(polyStr, varPropWithName, 'projector', 'full');

	% Call the solver
	[upperBoundVal solverMessage momentMatrix monoMapTable monoList] = findQuantumBound(polyOp, sdpLevel, hashGenMonoInfo);

	% Print result
	disp('Upper bound value = ');
	disp(upperBoundVal);
	disp('Solver message = ');
	disp(solverMessage);

	% Check if there is a rank loop
	disp('Rank Loop Result: ');
	[rankLoop rankMoment epsilon] = hasRankLoop(momentMatrix, sdpLevel,  monoList, polyOp.m_varProperties);
	if(rankLoop)
		disp('Rank loop occurs')
	else
		disp('Rank loop does NOT occur');
	end
	
	if(rankLoop)
		[cellProjector opState] = getOptimalProjector(momentMatrix, sdpLevel, monoList, polyOp.m_varProperties);
end