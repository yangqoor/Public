function v = getoptions(options, name, v0)
if nargin<3
    error('Not enough arguments.');
end

if isfield(options, name)
    v = eval(['options.' name ';']);
else
    v = v0;
end
end
