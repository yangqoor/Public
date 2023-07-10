%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        spectrogram3D.m
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
function spectrogram3D(obj, data, varargin)
%spectrogram3D()...
%Examples:
% fa = fanalier(48000);
% p0 = 0;
% for(n = 1:normalBufSize)
%     data0(n) = sin(p0);
%     p0 = p0 + 0.01;
% end;
%fa.spectrogram3D(data0,'spectrogram3D() demonstration',1024);
% 
    %Default arguments values
    windowSize = 256;
    description = ' ';

    %Arguments checking
    if(nargin > 4)
        error('Too many input arguments');
    end;

    %Assign arguments
    if((nargin == 3))
        if(isnumeric(varargin{1}))
            windowSize = varargin{1};
        else
            description = varargin{1};
        end;
    end;
    
    if((nargin == 4))
        if(isnumeric(varargin{1}))
            windowSize = varargin{1};
            description = varargin{2};
        else
            description = varargin{1};
            windowSize = varargin{2};
        end;
    end;

    % Create figure
    figure1 = figure;
    
    % Create axes
    axes1 = axes('Parent',figure1);
    box(axes1,'on');
    grid(axes1,'on');
    hold(axes1,'all');

    title(description);
    spectrogram(data, windowSize, 120,128, obj.sampleRate);
  
end

