%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        impRespCoefs.m
% Dependencies:    -
% 
% MATLAB v:        8.0.0 (R2012b)
% 
% Organization:    SAL
% Design by:       
% Feedback:                 
%                  ___
%
% License:         MIT
% 
% 
%  ADDITIONAL NOTES:
%  _________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function impRespCoefs(obj, num, denum, varargin)
%This function creates Impulse Response  plot using filter coefficients.
%
%Examples:
% b = [1,0];
% a = [1,0.7];
% fa = fanalyzer(48000);
% fa.impRespCoefs(b, a, 'impRespCoefs() demonstration');

    if(nargin > 4)
        error('Too many input arguments');
    end;

    %The all input arrays must have one dimention
    checkData{1} = num;
    checkData{2} = denum;
    for(n = 1:2)
        argSize = size(checkData{n});
        if((argSize(1) > 1 && argSize(2) ~= 1) || (argSize(2) > 1 && argSize(1) ~= 1))
            error('The input arguments can be only 1D arrays');
        end;
    end;

    %Calculating Impulse response
    [h,t]=impz(num,denum);

    figure1 = figure;

    axes1 = axes('Parent',figure1);
    box(axes1,'on');
    grid(axes1,'on');
    hold(axes1,'all');

    stem(t,h);

    xlabel('n->');
    ylabel('Amplitude');
    
    if(nargin == 4)
        title(varargin{1});
    end;

end

