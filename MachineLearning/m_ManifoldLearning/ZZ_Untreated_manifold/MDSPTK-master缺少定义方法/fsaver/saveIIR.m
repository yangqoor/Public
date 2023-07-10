%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        saveIIR.m
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
function saveIIR( fileName, numData, denumData, order, numberOfSets, varargin )
%SAVEIIR Summary of this function goes here
%   Detailed explanation goes here

    coefsNumberInSet = 2*(order + 1);

    %Check numerator
    numDataSz = size(numData);
    if((numDataSz(1) ~= numberOfSets) || (numDataSz(2) ~= coefsNumberInSet/2))
        %Check if can be rotated
        if(numDataSz(2) == numberOfSets) || (numDataSz(1) == coefsNumberInSet/2)
            numData = rot90(numData);
        else
            error('Unexpected input matrix size for numerator');
        end;
    end;
    
     %Check denumerator
    denumDataSz = size(denumData);
    if((denumDataSz(1) ~= numberOfSets) || (denumDataSz(2) ~= coefsNumberInSet/2))
        %Check if can be rotated
        if(denumDataSz(2) == numberOfSets) || (denumDataSz(1) == coefsNumberInSet/2)
            denumData = rot90(denumData);
        else
            error('Unexpected input matrix size for denumerator');
        end;
    end;
    
    %Add description if provided
    if(nargin > 5 && strcmp(varargin{1}, '') ~= 1)
        fid = fopen(fileName,'w');            
        if (fid ~= -1)
          fprintf(fid,'/* '); 
          fprintf(fid, '%s', varargin{1});
          fprintf(fid, ' */ ');
          fclose(fid);                     
        end
    end;
    
    %Prepare filter data header
    dataHeader = [fsaver.saveIIRID, numberOfSets, order];

    %Prepare and write output data
    i = 1;
    outputRow(coefsNumberInSet*numberOfSets + length(dataHeader) + 1) = 0;
    %Where 1 - control variable, number of elements in file
    
    for(n = 1:length(dataHeader))
       outputRow(i) = dataHeader(n);
       i = i + 1;
    end;
    
    for(n = 1:numberOfSets)
        for(m = 1:coefsNumberInSet/2)
            outputRow(i) = numData(n,m);
            i = i + 1;
        end;
        for(k = 1:coefsNumberInSet/2)
            outputRow(i) = denumData(n,k);
            i = i + 1;
        end;
    end;
    
    %Write number of coefficients without last for check at C-code
    outputRow(i) = length(outputRow) - length(dataHeader) - 1;
    
    dlmwrite(fileName, outputRow, 'delimiter', ',', '-append', 'precision', fsaver.writePrecision);
    
end

