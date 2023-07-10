%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        interpolateData.m
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
function data = interpolateData(obj, inData)
    
    %Check input array dimensions
    dataSz = size(inData);
    if((dataSz(1) > 1 && dataSz(2) ~= 1) || (dataSz(2) > 1 && dataSz(1) ~= 1))
        error('Input data must be 1D array')
    end;
    
    %Input array length checking
    if (length(inData) > length(obj.dataBuf))
        error('Input array length must be less then interpolated array');
    end;
    
    %Find negative values in vectors
    for (n = 1:length(inData))
        if (inData(n) < 0)
            error('Input array values must be more then 0')
        end;
    end;

    %Calculate
    data = zeros(1,length(obj.dataBuf));
    p = 1;
    step = length(obj.dataBuf)/length(inData); 
    for (m = 1:length(obj.dataBuf))
        data(m) = inData(p);
        if (m > step * p)
            p = p + 1;
        end;
    end;
    
end

