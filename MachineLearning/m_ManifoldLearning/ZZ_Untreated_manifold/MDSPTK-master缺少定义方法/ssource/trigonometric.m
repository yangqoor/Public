%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        trigonometric.m
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
function trigonometric(obj, varargin)   
%This function provide waves based sin/cos functions.
%Usage:
% ssource.trigonometric(amps, freqs, phase, dc); - where phase in radians
%Examples:
%
% Sine wave with frequency = 100 Hz:
% ss = ssource(5000,48000);
% ss.trigonometric(1, 100);
% ss.plotData();
%
% Other examples put without constructor calling and data plotting.
%
% Cosine wave with frequency = 100 Hz and dc = 1:
% ssource.trigonometric(1, 100, pi/2, 1);  
% 
% Sine wave with amplitude manipulation:
% ssource.trigonometric([1,0,1], 1000);
%
% Sine wave with frequency manipulation:
% ssource.trigonometric(1, [1000,2000,1000]); 
%
% Frequency chirp:
% F(2000) = 0;
% p = 100;
% for (t = 1:2000) F(t) = p; p = p + 0.5; end;
% ssource.trigonometric(1, F) - frequency chirp

    %Check input arguments
    if(nargin < 3)
        error('Too few input arguments, amplitude and frequency needed');
    elseif(nargin > 5)
        error('Too many input arguments');
    end;
     
    %The all input arrays must have one dimention
    for(n = 1:nargin - 1)
        argSize = size(varargin{n});
        if((argSize(1) > 1 && argSize(2) ~= 1) || (argSize(2) > 1 && argSize(1) ~= 1))
            error('The input arguments can be only 1D arrays');
        end;
    end;
    
    %Initialize input arguments
    amps = obj.interpolateData(varargin{1});
    freqs = obj.interpolateData(varargin{2});
    if(nargin > 3) phase = obj.interpolateData(varargin{3}); 
    else phase = zeros(1, length(obj.dataBuf)); end;
    if(nargin > 4) dc = obj.interpolateData(varargin{4}); 
    else dc = zeros(1, length(obj.dataBuf)); end;
    
    %Trigonometric waveform%
    p = 0; %Sample counter
    for (n = 1:length(obj.dataBuf))
        p = p + 1;
        obj.dataBuf(n) = amps(n) * sin(2*pi*freqs(n)*n/obj.sampleRate + phase(n)) + dc(n); 
        if (p >= obj.sampleRate/freqs(n))
            p=0;
        end;
    end;

end

