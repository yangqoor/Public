function [ G, SI ] = GLCM(varargin)
%GLCM_CLP Calculate Gray-Level Co-occurence Matrix
%   G = GLCM(I, gray_levels, x_step, y_step)
%
    [I, offset, gray_levels, image_range, makeSymmetric] = ParseInputs(varargin{:});

    slope = 0;
    if (image_range(2) - image_range(1)) > 0
        slope = gray_levels / (image_range(2) - image_range(1));
    end
    intercept = 1 - (slope * image_range(1));
    SI = floor(imlincomb(slope, I, intercept, 'double'));
    SI(SI > gray_levels) = gray_levels;
    SI(SI < 1) = 1;

    row_step = offset(1);
    col_step = offset(2);
    G = compute_glcm(SI, gray_levels, row_step, col_step);
    
    if makeSymmetric
        glcm_transpose = G.';
        G = G + glcm_transpose;
    end
end

%% compute_glcm
function G = compute_glcm(SI, gray_levels, row_step, col_step)
    G = zeros(gray_levels);

    s = size(SI);
    row_max = s(1);
    col_max = s(2);
    for row = 1:row_max
        for col = 1:col_max
            intensity = SI(row, col);
            row2 = row + row_step;
            col2 = col + col_step;
            if row2 <= row_max && col2 <= col_max
                intensity2 = SI(row2, col2);
                G(intensity, intensity2) = G(intensity, intensity2) + 1;
            end
        end
    end
end

%% ParseInputs - copied out of MatLab
function [I, offset, nl, gl, sym] = ParseInputs(varargin)
    narginchk(1,9);

    % Check I
    I = varargin{1};
    validateattributes(I,{'logical','numeric'},{'2d','real','nonsparse'}, ...
                  mfilename,'I',1);

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

        paramStrings = {'Offset','NumLevels','GrayLimits','Symmetric'};

        for k = 2:2:nargin
            param = lower(varargin{k});
            inputStr = validatestring(param, paramStrings, mfilename, 'PARAM', k);
            idx = k + 1;  %Advance index to the VALUE portion of the input.
            if idx > nargin
                error(message('images:glcm_clp:missingParameterValue', inputStr));        
            end

            switch (inputStr)
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
                        error(message('images:glcm_clp:invalidNumLevels'));
                    elseif islogical(I) && nl ~= 2
                        error(message('images:glcm_clp:invalidNumLevelsForBinary'));
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
                        error(message('images:glcm_clp:invalidGrayLimitsSize'));
                    end
                    gl = double(gl);

                case 'Symmetric'
                    sym = varargin{idx};
                    validateattributes(sym,{'logical'}, {'scalar'}, mfilename, 'Symmetric', idx);
            end
        end
    end
end
