%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        saveFIR.m
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
function saveFIR( fileName, data, order, numberOfSets, varargin )
%SAVEFIR Summary of this function goes here
%   Detailed explanation goes here
    
    coefsNumberInSet = order + 1;

    %Check input data
    dataSz = size(data);
    if((dataSz(1) ~= numberOfSets) || (dataSz(2) ~= coefsNumberInSet))
        %Check if can be rotated
        if(dataSz(2) == numberOfSets) || (dataSz(1) == coefsNumberInSet)
            data = rot90(data);
        else
            error('Unexpected input matrix data size');
        end;
    end;

    %Add description if provided
    if(nargin > 4 && strcmp(varargin{1}, '') ~= 1)
        fid = fopen(fileName,'w');            
        if (fid ~= -1)
          fprintf(fid,'/* '); 
          fprintf(fid, '%s', varargin{1});
          fprintf(fid, ' */ ');
          fclose(fid);                     
        end
    end;

    %Prepare filter data header
    dataHeader = [fsaver.saveFIRID, numberOfSets, order];
    
    %Prepare and write output data
    i = 1;
    outputRow(coefsNumberInSet*numberOfSets + length(dataHeader) + 1) = 0;
    %Where 1 - control variable, number of elements in file
    for(n = 1:length(dataHeader))
       outputRow(i) = dataHeader(n);
       i = i + 1;
    end;
    
    for(n = 1:numberOfSets)
        for(m = 1:coefsNumberInSet)
            outputRow(i) = data(n,m);
            i = i + 1;
        end;
    end;
    
    %Write number of coefficients without last for check at C-code
    outputRow(i) = length(outputRow) - length(dataHeader) - 1;
    
    dlmwrite(fileName, outputRow, 'delimiter', ',', '-append', 'precision', fsaver.writePrecision);
       
end

