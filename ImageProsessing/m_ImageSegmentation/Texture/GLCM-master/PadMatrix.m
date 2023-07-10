function [ZI] = PadMatrix(varargin)
%PADMATRIX Add padding around a matrix.
%   PM = PADMATRIX(M, padding) takes the input matrix M and adds padding
%   evenly around the matrix. By default the padding value is zeros. You
%   can use an alternative padding value by passing 'Value', followed by a 
%   number. For example PM = PADMATRIX(M, padding, 'Value', 1) would change
%   the padding value to one.
    [matrix, padding, value] = ParseInputs(varargin{:});
    
    [rows, cols] = size(matrix);
    ZI = repmat(value, rows + (2 * padding), cols + (2 * padding));
    ZI(padding + 1:end - padding, padding + 1:end - padding) = matrix;
end

%% ParseInputs - copied out of MatLab
function [M, padding, value] = ParseInputs(varargin)
    narginchk(1,3);

    M = varargin{1};
    validateattributes(M, {'logical', 'numeric'}, {'2d', 'real', 'nonsparse'}, ...
                  mfilename, 'M', 1);
              
    padding = varargin{2};
    validateattributes(padding, {'numeric'}, {'real'}, mfilename, 'padding', 2);       
    
    value = 0;
    if nargin > 2
        value = varargin{3};
        validateattributes(value, {'numeric'}, {'real'}, mfilename, 'value', 3); 
    end
end