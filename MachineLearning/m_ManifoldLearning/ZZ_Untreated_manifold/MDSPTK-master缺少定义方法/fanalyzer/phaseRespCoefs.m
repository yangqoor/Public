%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        phaseRespCoeofs.m
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
function phaseRespCoefs(obj, num, denum, varargin)
%This function creats phase response plot from filter coef's.
%
%Examples:
% fa = fanalier(48000);
% b = [1,0];
% a = [1,-0.7];
% data1 = zeros(1,shortBuobj.sampleRateize);
% data1(1) = 1;
% data1 = filter(b,a,data1);
% fa.phaseRespCoefs(b,a,'log','phaseRespCoefs demonstration');
%
%Notes:
% 'lin', plot in linear scales, 'log' - in log scales.
%

    %Arguments checking
    if(nargin > 5)
        error('Too many input arguments');
    end;

    %Assign arguments
    if(nargin == 4 && ((strcmp(varargin{1},'lin') ~= 1) && (strcmp(varargin{1},'log') ~= 1)))
        type = 'log';
        description = varargin{1};
    elseif(nargin == 5 && ((strcmp(varargin{1},'lin') ~= 1) && (strcmp(varargin{1},'log') ~= 1)))
        error(['Unsupported x-axis type: ' varargin{1}]);
    elseif(nargin == 3)
        type = 'log';
        description = ' ';   
    elseif(nargin == 4)
        type = varargin{1};
        description = ' ';
    elseif(nargin == 5)
        type = varargin{1};
        description = varargin{2};
    end;

    if((strcmp(type,'lin') ~= 1) && (strcmp(type,'log') ~= 1))
        error(['Unsupported x-axis type: ' type]);
    end;

    %Calculating phase
    [phi,F]=phasez(num, denum, obj.sampleRate);

    figure1 = figure;

    if((strcmp(type,'lin') == 1))
    % Create lin axes
        axes1 = axes('Parent',figure1);
        box(axes1,'on');
        grid(axes1,'on');
        hold(axes1,'all');
        plot((obj.sampleRate/2)*(F/pi),phi);
    end;

    if((strcmp(type,'log') == 1))
    % Create log axes
        axes1 = axes('Parent',figure1,'XScale','log','XMinorTick','on','XMinorGrid','on');
        box(axes1,'on');
        grid(axes1,'on');
        hold(axes1,'all');
        plot((obj.sampleRate/2)*(F/pi),phi);
    end;

    title(description);
    xlabel('f->');
    ylabel('\angle H(f)/\pi \rightarrow');

end

