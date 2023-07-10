% The function: specifyGenListMonoCriteria(C)
%
% The function return a specification of the criteria that a list of monomials of order d can be generated. For example,
%			+ At least how many partition must be present in the list of monomials of order d?
%			+ Do we generate all the list of monomials of order d? or
%			+ How many elements do we want to randomly choose from the list of some monomials of order d?
%
% Input: (The function can take no argument or varargin{1} can be a string 'default')
%	+ C is a cell. Each element is again a cell E such that:
%		- E{1}: an integer indicating the order (length) of monomials.
%		- E{2}: an integer indicating the number of partition that should be present in a monomial (i.e. a monomial generated should contain
%						at least E{2} instances of variables from E{2} different partitions)
%				E{2} = 0 means there is no restriction on monomials in terms of the number of partitions present.
%		- E{3}: a string. There are only 2 cases:
%					+ E{3} = 'full' means we take all monomials that satisfy E{1} and E{2}. If E{3} = 'full', there is no need to input E{4} and E{5}
%					+ E{3} = 'random' means we choose randomly some elements from the list of all monomials that satisfy E{1} and E{2}
%		- E{4}: a number.
%		- E{5}: a string. There are only 2 cases:
%					+ E{5} = 'absolute' means E{4} is an integer indicating the number of monomials we choose randomly.
%					+ E{5} = 'ratio' means E{4} is a real number indicating the percentage over the total number of satisfying monomials that
%							we choose randomly.
%
% Output:
%	+ H: a hash table that maps the order of monomials to a cell containing information E{2}, E{3}, E{4}
%	+ If nargin == 0 or varargin{1} is a string 'default', return the empty hash.

function hashGenMonoInfo = specifyGenListMonoCriteria(varargin)
	hashGenMonoInfo = containers.Map('KeyType', 'int32', 'ValueType', 'any');

	if nargin == 0
		return;		% Return empty hash table
	end

	if isstr(varargin{1}) && strcmpi(varargin{1}, 'default')
		return;
	end

	if ~iscell(varargin{1})
		error('Invalid argument. The function takes no argument, or a string "default", or a cell');
	end

	numCriteria = length(varargin{1});

	for index = 1 : numCriteria
		if ~iscell(varargin{1}{index})
			error('Invalid argument. Only cells are accepted!');
		end

		numArg = length(varargin{1}{index});

		if numArg < 3
			error('There must be at least 3 arguments for each level specification!');
		end

		if strcmpi(varargin{1}{index}{3}, 'full')
			hashGenMonoInfo(varargin{1}{index}{1}) = varargin{1}{index}(2 : 3);
		elseif strcmpi(varargin{1}{index}{3}, 'random')
			if numArg < 5
				error('If you choose "random" option, there must be 5 arguments for the level specification');
			end

			hashGenMonoInfo(varargin{1}{index}{1}) = varargin{1}{index}(2 : 5);
		end
	end
end