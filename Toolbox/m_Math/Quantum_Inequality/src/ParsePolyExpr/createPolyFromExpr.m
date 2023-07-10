% createPolyFromExpr(E, varPropWithName, varTypeName): generate a polynomial object in non-commutative variables from an arithmetic expression E.
%
% (Under construction to remove more constraints on the form of E)
%
% Input:
%	+ E: an arithmetic expression.
%	
%	+ varProp: a cell of size 1 x n where n is the number of partitions.
%		-If varType = 0 (Projector):
%			Each element in C is a cell of size 1 x m where m is the number of inputs of
%				the measurements.
%			Each cell has elements as cells. Each cell contains variable names.
%
%		- If varType = 1 (Observable):
%			Each element in C is a cell that contains names of variables in the same partition.
%
%	+ varType: a string 'observable' or 'projector'
%	+ isFullOrPartial (varargin{1}): (only applicable to projector case)
%		- isFullOrPartial = 'full' if all projector measurements are present in varPropWithName.
%		- isFullOrPartial = 'partial' if some projector measurements are absent
%
% Output:
%	+ poly: a polynomial object built from the input expression.
%
%	+ reducedVarHash: (only applicable to the projector case and when isFull = 1) a hash table that maps the name of a redundant variable (in this case,
%			we choose that last variable in each input group (or measurement setting)) to a vector of integers representing serial numbers of other
%			variables in the same input group (or measurement setting)
%
% Assumption: inputs are valid and satisfied all the constraints.
function [polyObj, reducedVarHash] = createPolyFromExpr(expr, varPropWithName, varTypeName, varargin)
	varType = 0;	% Dummy value
	if strcmpi(varTypeName, 'observable')
		varType = 1;
	elseif strcmpi(varTypeName, 'projector')
		varType = 0;
	else
		error('Variable type should be either PROJECTOR or OBSERVABLE');
	end

	if ~varType
		% Projector case
		if isempty(varargin)
			error('One argument is missing for the project case. Should specify "full" or "partial"');
		end

		if strcmpi(varargin{1}, 'full')
			isFull = 1;
		elseif strcmpi(varargin{1}, 'partial')
			isFull = 0;
		else
			error('Should specify "full" or "partial" only');
		end
	else
		isFull = 1;		% Dummy value
	end

	[varInfoHash, varProp, reducedVarHash] = preprocessVarProp(varPropWithName, varType, isFull);

	% Convert from infix to postfix notation
	exprPost = infixToPostfix(expr);

	polyVarHash = createPolyObjForVar(varInfoHash, varProp, varType, reducedVarHash);

	polyObj = evaluatePolyExpr(exprPost, polyVarHash);
end