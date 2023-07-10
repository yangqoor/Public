%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        phaseResp.m
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
function  phaseResp(obj, data, varargin)
%This function compute and plot phase.
%
%Examples:
% fa = fanalier(48000);
% b = [1,0];
% a = [1,-0.7];
% data1 = zeros(1,shortBuobj.sampleRateize);
% data1(1) = 1;
% data1 = filter(b,a,data1);
% fa.phaseResp(data1,'log','phaseResp() demonstration');
%
%Notes:
% 'lin', plot in linear scales, 'log' - in log scales.
%

fosi=10;

N=length(data);

a=zeros(1,N);
a(1)=1;

    %Arguments checking
    if(nargin > 4)
        error('Too many input arguments');
    end;

    %Assign arguments
    if(nargin == 3 && ((strcmp(varargin{1},'lin') ~= 1) && (strcmp(varargin{1},'log') ~= 1)))
        type = 'log';
        description = varargin{1};
    elseif(nargin == 4 && ((strcmp(varargin{1},'lin') ~= 1) && (strcmp(varargin{1},'log') ~= 1)))
        error(['Unsupported x-axis type: ' varargin{1}]);
    elseif(nargin == 2)
        type = 'log';
        description = ' ';   
    elseif(nargin == 3)
        type = varargin{1};
        description = ' ';
    elseif(nargin == 4)
        type = varargin{1};
        description = varargin{2};
    end;

    if((strcmp(type,'lin') ~= 1) && (strcmp(type,'log') ~= 1))
        error(['Unsupported x-axis type: ' type]);
    end;

    %denominator polynom:
    a=zeros(1,N);
    a(1)=1;

    %Calculating Magnitudes
    mxsz = size(data);
    if(mxsz(1) < mxsz(2))
        data = reshape(data,mxsz(2),mxsz(1));
    end;
    mxsz = size(data);
    for n=1:mxsz(2)
        [H1(:,n),F]=freqz(data(:,n),a,65536,obj.sampleRate);
    end;

    figure1 = figure;

    if((strcmp(type,'lin') == 1))
    % Create lin axes
        axes1 = axes('Parent',figure1);
        box(axes1,'on');
        grid(axes1,'on');
        hold(axes1,'all');

        plot(F,unwrap(angle(H1))/pi);
    end;

    if((strcmp(type,'log') == 1))
    % Create log axes
        axes1 = axes('Parent',figure1,'XScale','log','XMinorTick','on','XMinorGrid','on');
        box(axes1,'on');
        grid(axes1,'on');
        hold(axes1,'all');

        plot(F,unwrap(angle(H1))/pi);
    end;

    title(description,'Fontsize',fosi);
    xlabel('f->');
    ylabel('\angle H(f)/\pi \rightarrow','Fontsize',fosi)

end

