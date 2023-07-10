%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        timePlotSamples.m
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
function timePlotSamples(obj, varargin)
%This function plots 1D data using stem() matlab function. 
%Same as timePlot().
%

    %Arguments checking
    if(nargin < 2)
        error('Too few input arguments, data array must be provided');
    elseif(nargin > 3)
        error('Too many input arguments');
    end;
    
    %The all input arrays must have one dimention
    for(n = 1:nargin - 1)
        argSize = size(varargin{n});
        if((argSize(1) > 1 && argSize(2) ~= 1) || (argSize(2) > 1 && argSize(1) ~= 1))
            error('The input arguments can be only 1D arrays');
        end;
    end;
    
    data = varargin{1};
        
    %Create figure and plot data

    figure1 = figure;

    axes1 = axes('Parent',figure1);
    box(axes1,'on');
    grid(axes1,'on');
    hold(axes1,'all');

    dataSz = size(data);
    
    %Correct matrix before stem calling
    if(dataSz(1) < dataSz(2))
        data = rot90(data);
    end
    
    stem((1:length(data)), data,'Marker','none'); 

    xlabel('n->');
    ylabel('Amplitude');

    if(nargin == 3)
        title(varargin{2});
    end;
    
end

