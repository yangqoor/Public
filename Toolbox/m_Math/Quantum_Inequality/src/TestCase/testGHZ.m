% The function: testGHZ(sdpLevel)
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
%	+ GHZ Inequality: a XOR b XOR c = 0 if stu = 000, and = 1 if stu is either 011, 101, 110
%	+ Find an upper bound of:
%		P = 1/4 * (Aa0_s0 * Bb0_t0 * Cc0_u0 + Aa1_s0 * Bb1_t0 * Cc0_u0 + Aa0_s0 * Bb1_t0 * Cc1_u0 + Aa1_s0 * Bb0_t0 * Cc1_u0 +
%				   Aa1_s0 * Bb1_t1 * Cc1_u1 + Aa0_s0 * Bb0_t1 * Cc1_u1 + Aa1_s0 * Bb0_t1 * Cc0_u1 + Aa0_s0 * Bb1_t1 * Cc0_u1 +
%				   Aa1_s1 * Bb1_t0 * Cc1_u1 + Aa0_s1 * Bb0_t0 * Cc1_u1 + Aa1_s1 * Bb0_t0 * Cc0_u1 + Aa0_s1 * Bb1_t0 * Cc0_u1 +   
%				   Aa1_s1 * Bb1_t1 * Cc1_u0 + Aa0_s1 * Bb0_t1 * Cc1_u0 + Aa1_s1 * Bb0_t1 * Cc0_u0 + Aa0_s1 * Bb1_t1 * Cc0_u0)      
%	+ All variables are projectors.
%	+ There are 3 partitions (parties) A = {{Aa0_s0, Aa1_s0}, {Aa0_s1, Aa1_s1}} and B = {{Bb0_t0, Bb1_t0}, {Bb0_t1, Bb1_t1}} and C = {{Cc0_u0, Cc1_u0}, {Cc0_u1, Cc1_u1}}
function [upperBoundVal solverMessage] = testGHZ(varargin)
	sdpLevel = 2;
	hashGenMonoInfo = specifyGenListMonoCriteria();
	if nargin > 0
		sdpLevel = varargin{1};
	end
	if nargin > 1
		hashGenMonoInfo = varargin{2};
	end
	
	polyStr = '1/4 *(Aa0_s0 * Bb0_t0 * Cc0_u0 + Aa1_s0 * Bb1_t0 * Cc0_u0 + Aa0_s0 * Bb1_t0 * Cc1_u0 + Aa1_s0 * Bb0_t0 * Cc1_u0 + Aa1_s0 * Bb1_t1 * Cc1_u1 + Aa0_s0 * Bb0_t1 * Cc1_u1 + Aa1_s0 * Bb0_t1 * Cc0_u1 + Aa0_s0 * Bb1_t1 * Cc0_u1 + Aa1_s1 * Bb1_t0 * Cc1_u1 + Aa0_s1 * Bb0_t0 * Cc1_u1 + Aa1_s1 * Bb0_t0 * Cc0_u1 + Aa0_s1 * Bb1_t0 * Cc0_u1 + Aa1_s1 * Bb1_t1 * Cc1_u0 + Aa0_s1 * Bb0_t1 * Cc1_u0 + Aa1_s1 * Bb0_t1 * Cc0_u0 + Aa0_s1 * Bb1_t1 * Cc0_u0)';
	varPropWithName = {{{'Aa0_s0', 'Aa1_s0'}, {'Aa0_s1', 'Aa1_s1'}}, {{'Bb0_t0', 'Bb1_t0'}, {'Bb0_t1', 'Bb1_t1'}}, {{'Cc0_u0', 'Cc1_u0'}, {'Cc0_u1', 'Cc1_u1'}}};
	[polyOp reduceVar] = createPolyFromExpr(polyStr, varPropWithName, 'projector', 'full');
	
	% Call the solver
	[upperBoundVal solverMessage momentMatrix monoMapTable monoList]  = findQuantumBound(polyOp, sdpLevel, hashGenMonoInfo);
end