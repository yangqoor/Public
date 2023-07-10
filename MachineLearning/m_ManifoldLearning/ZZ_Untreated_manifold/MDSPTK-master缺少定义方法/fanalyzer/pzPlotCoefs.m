%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        pzPlotCoefs.m
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
function pzPlotCoefs(obj, num,denum, varargin)
%This function compute pole-zero plot from filter coefs.
%
%Examples:
% b = [1,0];
% a = [1,-0.7];
% fa = fanalyzer(48000);
%fa.pzPlotCoefs(b,a,'pzPlotCoefs() demonstration');
%

    fosi=10;

    %Arguments checking
    if (nargin >4)
        error('Too many input arguments');
    end;

    figure1 = figure;

    % Create axes
    axes1 = axes('Parent',figure1);
    box(axes1,'on');
    grid(axes1,'on');
    hold(axes1,'all');

    zplane(num,denum);

    if(nargin == 4)
        title(varargin{1},'Fontsize',fosi);
    end;
    
    xlabel('Re(z)','Fontsize',fosi)
    ylabel('Im(z)','Fontsize',fosi)


end
