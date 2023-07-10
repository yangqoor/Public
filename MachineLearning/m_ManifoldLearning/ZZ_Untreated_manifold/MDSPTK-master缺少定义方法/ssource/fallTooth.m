%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        fallTooth.m
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
function fallTooth(obj, amps, freqs)
%Fall tooth wave will generated.
%Usage:
% ssource.fallTooth(amps, freqs);
%Examples:
%
% Fall tooth wave with frequency = 100 Hz:
% ssource.fallTooth(1, 100);
    
    checkData{1} = amps;
    checkData{2} = freqs;
    for(n = 1:2)
        argSize = size(checkData{n});
        if((argSize(1) > 1 && argSize(2) ~= 1) || (argSize(2) > 1 && argSize(1) ~= 1))
            error('The input arguments can be only 1D arrays');
        end;
    end;
    
    amps = obj.interpolateData(amps);
    freqs = obj.interpolateData(freqs);
    
    p=0;
    curAmp = amps(1);
    curFreq = freqs(1);
    for (n = 1:length(obj.dataBuf))
        p = p + 1;
        if (p < (obj.sampleRate/freqs(n)))
            obj.dataBuf(n) = curAmp*(1 - p/(obj.sampleRate/curFreq));  
        else
            obj.dataBuf(n) = 0;
        end;   
        if (p >= obj.sampleRate/freqs(n))
            p = 0;
            curAmp = amps(n);
            curFreq = freqs(n);
        end;   
    end;       

end