%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        timePlot.m
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
function timePlot(obj, varargin)
%This function plots 1D data.
%
%Examples:
% p0 = 0;
% for(n = 1:normalBufSize)
%     data0(n) = sin(p0);
%     p0 = p0 + 0.01;
% end;
% 
% fa = fanalyzer(fs);
% fa.timePlot(data0);
%

    %Arguments checking
    if(nargin < 2)
        error('Too few input arguments, data array must be provided');
    elseif(nargin > 3)
        error('Too many input arguments');
    end;
    
    %The all input arrays must have one dimention
   % for(n = 1:nargin - 1)
   %     argSize = size(varargin{n});
   %     if((argSize(1) > 1 && argSize(2) ~= 1) || (argSize(2) > 1 && argSize(1) ~= 1))
   %         error('The input arguments can be only 1D arrays');
   %     end;
   % end;
    
    data = varargin{1};
        
    %Create figure and plot data
    figure1 = figure;

    axes1 = axes('Parent',figure1);
    box(axes1,'on');
    grid(axes1,'on');
    hold(axes1,'all');

    mxsz = size(data);
    for (n=1:mxsz(1))
        plot((0:length(data(1,:))-1)/obj.sampleRate, data(n,:),'Marker','none');
    end;
    
    xlabel('seconds->');
    ylabel('Amplitude');
    
    if(nargin == 3)
        title(varargin{2});
    end;

end

