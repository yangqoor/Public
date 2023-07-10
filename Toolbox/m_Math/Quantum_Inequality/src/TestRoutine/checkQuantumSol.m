% The function: checkQuantumSol(opMeasure, opState, inputPoly, upperBound, momentMatrix, cellMono)
%
% Inputs:
%	+ opMeasure: a cell in which the i-th entry is the matrix representing the value of the variable of serial number i.
%	+ opState: a vector of the quantum states.
%	+ inputPoly: the polynomial structure which we want to optimize.
%	+ upperBound: the maximum upper bound of inputPoly produced by findQuantumBound function.
%	+ momentMatrix: the moment matrix in the SDP.
%	+ cellMono: an ordered list of monomials by which the moment matrix is indexed.
%
% Outputs:
%	+ result = 1 if opMeasure and opState is a solution of the quantum probability problem, i.e.
%		- upperBound is the result of evaluating inputPoly at opMeasure and opState.
%		- momentMatrix can be constructed using opMeasure, opState and cellMono!
%		- Matrices in opMeasure must satify:
%			+ Commutativy constraints!
%			+ Observable constaints (if they are observables)
%			+ Orthogonality constaints (if they are projectors)
%  	+ result = 0 otherwise.
%	+ epsilon: (In case result = 1) a positive real number. Any number x such that -epsilon < x < epsilon will be considered as 0. It is 
%				the tolerance for which result = 1
function [result, epsilon] = checkQuantumSol(opMeasure, opState, inputPoly, upperBound, momentMatrix, cellMono)
	epsilon = 1e-12;	% Dummy value
	% Check upper bound condition
	opVal = evaluatePolynomial(inputPoly, opMeasure, opState);
	difference = opVal - upperBound;
	resultOne = 0;
	epOne = 1e-12;
	while epOne < 1e-5
		if abs(difference) < epOne
			resultOne = 1;
			break;
		end
		epOne = epOne * 10;
	end

	if ~resultOne
		result = 0;
		return;
	end

	disp('Check bound value: Passed');
	disp('epsilon = ');
	disp(epOne);

	% Check moment matrix condition
	[resultTwo epTwo] = checkMomentVarValue(momentMatrix, inputPoly, cellMono, opMeasure, opState);
	if ~resultTwo
		result = 0;
		return;
	end


	disp('Check Moment Variable Value: Passed');
	disp('epsilon = ');
	disp(epTwo);

	% Check commutativity
	numVar = length(opMeasure);
	% Find the first variable in the second partition
	if ~inputPoly.m_varType
		% Projector
		wantVar = inputPoly.m_varProperties{2}{1}(1);
	else
		% Observable
		wantVar = inputPoly.m_varProperties{2}(1);
	end
	[resultThree epThree] = checkCommute(opMeasure(1 : wantVar - 1), opMeasure(wantVar : numVar));
	if ~resultThree
		result = 0;
		return;
	end

	disp('Check commutativity: Passed');
	disp('epsilon = ')
	disp(epThree);

	if ~inputPoly.m_varType
		% Check orthogonality conditions
		[resultFour epFour] = checkProjector(opMeasure, inputPoly);
	else
		[resultFour epFour] = checkObservable(opMeasure);
	end

	if ~resultFour
		result = 0;
		return;
	end

	disp('Check variable type constraints: Passed');
	disp('epsilon = ');
	disp(epFour);

	result = 1;
	epsilon = max([epOne epTwo epThree epFour]);
end
