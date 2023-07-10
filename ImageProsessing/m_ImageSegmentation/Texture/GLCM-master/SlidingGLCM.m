function [results, ZI] = SlidingGLCM(varargin)
%SLIDING_GLCM GLCM using a sliding window.
%   Detailed explanation goes here
    [I, window_size, offset, gray_levels, gray_limits, symmetric] = ParseInputs(varargin{:});
    
    progress_string = '';
    variance = zeros(size(I));
    contrast = zeros(size(I));
    entropy = zeros(size(I));
    inertia = zeros(size(I));
    homogeneity = zeros(size(I));
    cluster_shade = zeros(size(I));
    quadrants = zeros(size(I, 1), size(I, 2), 8);
    half_size = floor(window_size / 2);
    ZI = PadMatrix(I, half_size);
    
    % i and j are related to the number of gray levels we'll be evaluating
    i = repmat((0:(gray_levels - 1))', 1, gray_levels);
    j = repmat( 0:(gray_levels - 1)  , gray_levels, 1);
    ij_sq = (i - j).^2;
    
    index = 1;
    [rows, cols] = size(I);
    for row = 1:rows
        for col = 1:cols
            % fprintf('[%d, %d]\n', row, col);
            row2 = row + (half_size * 2);
            col2 = col + (half_size * 2);
            sliding_window = ZI(row:row2, col:col2);
            
            G = GLCM(sliding_window, 'NumLevels', gray_levels, 'Offset', offset, 'GrayLimits', gray_limits, 'Symmetric', symmetric);
            p = G ./ sum(G(:));
            mu = sum(sum(p .* (i + 1)));
            
            % Sum of squares, Variance
            variance(row, col) = sum(sum(p .* ((i - mu).^2)));
            % Should be equivalent whether using i or j.
            % variance(row, col) = sum(sum(glcm .* ((j - mu).^2)));

            % sum(n^2)0_g-1 * sum(sum(p_ij))
            % 0 1 4 9 16 25 36 49
            contrast(row, col) = sum(sum(p .* ij_sq));
            
            non_zero_glcm = p(p > 0);
            entropy(row, col) = -sum(non_zero_glcm .* log2(non_zero_glcm));
            
            inertia(row, col) = sum(sum(p .* ij_sq));
            
            homogeneity(row, col) = sum(sum(p ./ (1 + abs(i - j))));
            
            % cluster_shade = sum sum (i + j - mu_x - mu_y)^3 * p_ij
            u_x = sum(sum(p .* (i + 1)));
            u_y = sum(sum(p .* (j + 1)));
            cluster_shade(row, col) = sum(sum((i + j - u_x - u_y).^3));
            
            [feature1, feature2, feature3, feature4] = QuadrantEnergy(p);
            [top_left, top_right, bottom_right, bottom_left] = Quadrants(p);
            [feature5, feature6, feature7, feature8] = QuadrantEnergy(top_left);
            quadrants(row, col, :) = [feature1 feature2 feature3 feature4 ...
                   feature5 feature6 feature7 feature8];

            msg = sprintf('Percent done: %3.2f', (index / (rows * cols)) * 100);
            fprintf([progress_string, msg]);
            progress_string = repmat(sprintf('\b'), 1, length(msg));
            index = index + 1;
        end
    end    
    
    fprintf('\n');
    results = struct('variance', variance, ...
                     'contrast', contrast, ...
                     'entropy', entropy, ...
                     'inertia', inertia, ...
                     'homogeneity', homogeneity, ...
                     'cluster_shade', cluster_shade, ...
                     'quadrants', quadrants);
end

%% ParseInputs - copied out of MatLab
function [I, ws, offset, nl, gl, sym] = ParseInputs(varargin)
    narginchk(1,11);

    % Check I
    I = varargin{1};
    validateattributes(I, {'logical', 'numeric'}, {'2d', 'real', 'nonsparse'}, ...
                  mfilename, 'I', 1);

    % Assign Defaults
    offset = [0 1];
    if islogical(I)
      nl = 2;
    else
      nl = 8;
    end
    gl = getrangefromclass(I);
    sym = false;

    % Parse Input Arguments
    if nargin ~= 1

        paramStrings = {'WindowSize','Offset','NumLevels','GrayLimits','Symmetric'};

        for k = 2:2:nargin
            param = lower(varargin{k});
            inputStr = validatestring(param, paramStrings, mfilename, 'PARAM', k);
            idx = k + 1;  %Advance index to the VALUE portion of the input.
            if idx > nargin
                error(message('images:SlidingGLCM:missingParameterValue', inputStr));        
            end

            switch (inputStr)
                case 'WindowSize'
                    ws = varargin{idx};
                    validateattributes(nl, {'logical', 'numeric'}, ...
                        {'real', 'integer', 'nonnegative', 'nonempty', 'nonsparse'}, ...
                        mfilename, 'WS', idx);
                    if numel(ws) > 1
                        error(message('images:SlidingGLCM:invalidWindowSize'));
                    end
                    ws = double(ws);
                case 'Offset'
                    offset = varargin{idx};
                    validateattributes(offset,{'logical','numeric'},...
                        {'2d','nonempty','integer','real'},...
                        mfilename, 'OFFSET', idx);
                    if size(offset,2) ~= 2
                        error(message('images:graycomatrix:invalidOffsetSize'));
                    end
                    offset = double(offset);
                case 'NumLevels'
                    nl = varargin{idx};
                    validateattributes(nl,{'logical','numeric'},...
                        {'real','integer','nonnegative','nonempty','nonsparse'},...
                        mfilename, 'NL', idx);
                    if numel(nl) > 1
                        error(message('images:SlidingGLCM:invalidNumLevels'));
                    elseif islogical(I) && nl ~= 2
                        error(message('images:SlidingGLCM:invalidNumLevelsForBinary'));
                    end
                    nl = double(nl);       
                case 'GrayLimits' 
                    gl = varargin{idx};
                    % step 1: checking for classes
                    validateattributes(gl,{'logical','numeric'},{},mfilename, 'GL', idx);
                    if isempty(gl)
                        gl = [min(I(:)) max(I(:))];
                    end

                    % step 2: checking for attributes
                    validateattributes(gl,{'logical','numeric'},{'vector','real'},mfilename, 'GL', idx);

                    if numel(gl) ~= 2
                        error(message('images:SlidingGLCM:invalidGrayLimitsSize'));
                    end
                    gl = double(gl);

                case 'Symmetric'
                    sym = varargin{idx};
                    validateattributes(sym,{'logical'}, {'scalar'}, mfilename, 'Symmetric', idx);
            end
        end
    end
end