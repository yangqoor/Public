%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        spectrogram.m
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
function spectrogram(obj, data, varargin)
%cmSpectrogram() plots the spectorgram of input array. 
%
%Examples:
% p0 = 0;
% for(n = 1:normalBufSize)
%     data0(n) = sin(p0);
%     p0 = p0 + 0.01;
% end;
% fa.specrogram(data0,'log','spectrogram() demonstration');
%
%Notes:
% 'lin', plot in linear scales, 'log' - in log scales.
%

    %FFT window size
    NFFT = 65536;

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

    %Calculate magnitudes
    mxsz = size(data);
    if(mxsz(1) < mxsz(2))
        data = reshape(data,mxsz(2),mxsz(1));
    end;
    mxsz = size(data);
    for n=1:mxsz(2)
        H1(:,n) = fft(data(:,n),NFFT)/length(data(:,1));
    end;

    % Create figure, compute and plot data
    figure1 = figure;

    if((strcmp(type,'lin') == 1))
    % Create lin axes
        axes1 = axes('Parent',figure1);
        box(axes1,'on');
        grid(axes1,'on');
        hold(axes1,'all');

        f1 = obj.sampleRate/2*linspace(0,1,NFFT/2+1);
        plot(f1,2*abs(H1(1:NFFT/2+1,:)));
    end;

    if((strcmp(type,'log') == 1))
    % Create log axes
        axes1 = axes('Parent',figure1,'XScale','log','XMinorTick','on',...
            'XMinorGrid','on');
        box(axes1,'on');
        grid(axes1,'on');
        hold(axes1,'all');

        f1 = obj.sampleRate/2*linspace(0,1,NFFT/2+1);
        plot(f1,2*abs(H1(1:NFFT/2+1,:)));
    end;

    title(description);

    xlabel('f->');
    ylabel('Amp');

end
