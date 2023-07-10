%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        polarComplexFreqCoefs.m
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
function polarComplexFreqCoefs(obj, num, denum, varargin)
%This function compute normalized complex frequebcy-response  plot.
%
%Examples:
% b = [1,0];
% a = [1,-0.7];
% fa = fanalyzer(48000);
%fa.polarComplexFreqCoefs(b,a,'pzPlotCoefs() demonstration');
%

    fosi=10;

    %Arguments checking
    if (nargin >4)
        error('Too many input arguments');
    end;

    % Create figure
    figure1 = figure;

    % Create axes
    axes1 = axes('Parent',figure1);
    box(axes1,'on');
    grid(axes1,'on');
    hold(axes1,'all');

    [h, w] = freqz(num,denum);
    plot((h)/max(h));

    axis equal;
    axis square;
    axis([-1 1 -1 1]);
    line([0 0],[-1 1]);
    line([-1 1],[0 0]);
    xlabel Real;
    ylabel Imag;

    if(nargin == 4)
        title(varargin{1},'Fontsize',fosi);
    end;
    
    xlabel('Re(z)','Fontsize',fosi)
    ylabel('Im(z)','Fontsize',fosi)

end
