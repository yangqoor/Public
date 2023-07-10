% The function: NonCommutePolynomial(varargin)
%
% Returns a structure representing a polynomial in non-commutative variables.
%
% The structure has the following fields:
%
%	1) m_varProperties:
%		+ m_varProperties is a cell of size 1 x n where n is the number of partitions.
%		+ If m_varType = 0 (Projector):
%				Each element in m_varProperties is a cell of size 1 x m where m is the number of inputs of
%				the measurements.
%				Each cell has elements as arrays. Each array contains integers representing variables.
%		+ If m_varType = 1 (Observable):
%				Each element in m_varProperties is an array that contains integers which indicate variables
%				in the same partition.
%		+ In total, m_varProperties contains m_numVar integers (from 1 to m_numVar) which represents
%		  variables.
% 	2) m_inputGroup:
%		+ If m_varType = 1: m_inputGroup is empty.
%		+ If m_varType = 0:
%			m_varType is an array of size 1 x m_numVar. And m_varType[i] = X when the variable i
%			belongs to the input group X (where X = 1, ..., m where m is the number of inputs of
%			measurements)
%	3) m_cellMonomial: a cell of monomials in non-commutative variables.
%	4) m_degree: an integer indicating degree of the polynomial.
%		+ Only a zero polynomial has m_degree = -2147483648 (intmin('int32')) < 0.
%		+ The others have m_degree >= 0.
%	5) m_varType: Projector(0) or Observable(1)

% Constructor
function obj = NonCommutePolynomial(varargin)
	if nargin == 0
		% Use default constructor: create a constant zero polynomial
		% A zero polynomial must contain only the zero monomial
		% The degree should be -2147483648 (intmin('int32')).
		%
		% Other variables are not important so they can be set to 0 or empty
		obj.m_cellMonomial = {NonCommuteMonomial()};
		obj.m_degree = -2147483648;
		obj.m_numVar = 0;
		obj.m_varProperties = {};
		obj.m_varType = 0;
		obj.m_inputGroup = [];
		return;
	end
	
	if isstruct(varargin{1})
		% We assume varargin{1} is a structure of polynomials with all the required fields.
		% We use the copy constructor
		obj = varargin{1};
        	return;
	end
	
	% Use the full constructor
	% varargin MUST have 3 elements
	% 1) varargin{1}: a cell of monomials. Its size must be 1 x n where n >= 1.
	% 2) varargin{2}: varProperties. This will be assigned to m_varProperties. Thus, it should
	%					satisfy conditions specified in m_varProperties.
	% 3) varargin{3}: varType. It must be 0 or 1.
	%
	% Optional parameters:
	% 4) varargin{4}: inputGroup
 	%
	% Assumption: we assume inputs are correct and 'nice' since this class is used internally.
	%	For instance, varargin{1} does not contain the zero monomial. All monomials are distinct.
	%
	% If varargin{1} is empty, we create a zero polynomial.
	% Note that in our representation of zero polynomial, m_varPropertoes, m_inputGroup, m_varType, m_numVar are not important. So
	% they can be set to 0 or empty!
	if isempty(varargin{1})
		obj.m_cellMonomial = {NonCommuteMonomial()};
		obj.m_degree = -2147483648;
		obj.m_numVar = 0;
		obj.m_varProperties = {};
		obj.m_varType = 0;
		obj.m_inputGroup = [];
		return;
	end

	% Assign values
	obj.m_cellMonomial = varargin{1};
	obj.m_varProperties = varargin{2};
	obj.m_varType = varargin{3};
    	% Calculate number of variables
	obj.m_numVar = 0;
 	if obj.m_varType == 1       % Observable case
    		obj.m_numVar = length(obj.m_varProperties);
 	else                        % Projector case
    		for partitionNo = 1 : length(obj.m_varProperties)
			obj.m_numVar = obj.m_numVar + length(obj.m_varProperties{partitionNo});
		end
 	end

	flagInputGroup = 0;
	if nargin >= 4
		obj.m_inputGroup = varargin{4};
		flagInputGroup = 1;
	end
			
	% Calculating degree
	obj.m_degree = findMaxDegreeMonomial(varargin{1});
			
	% Create the m_inputGroup array
	if ~flagInputGroup
		numInputGroup = 0;
		if obj.m_varType == 1		% Observable case
			obj.m_inputGroup = [];
		else						% Projector case
			% Initialize an array 'inputGroup'
			obj.m_inputGroup = zeros(1, obj.m_numVar);
				
			% Access partitions
			for partitionNo = 1 : length(obj.m_varProperties)
				% Access groups in a partition
				for group = 1 : length(obj.m_varProperties{partitionNo})
					if ~isempty(obj.m_varProperties{partitionNo}{group})
						% Increment the current number of inputGroup if the group is non-empty.
						numInputGroup = numInputGroup + 1;
						% All variables in the same group will have the same inputGroup value.
						% Matlab Syntax: A(B) = val is equivalent to A[i] = val for all i belongs to the index vector B.
						obj.m_inputGroup(obj.m_varProperties{partitionNo}{group}) = numInputGroup;
					end
				end
			end
		end
	end
end
