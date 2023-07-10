%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        savePlaneData.m
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
function savePlaneData( fileName, data, numberOfSets, varargin )
%SAVEPLANEDATA Summary of this function goes here
%   Detailed explanation goes here

     %Check input data
    dataSz = size(data);
    if((dataSz(1) ~= numberOfSets))
        data = rot90(data);
    end;

    %Add description if provided
    if(nargin > 3 && strcmp(varargin{1}, '') ~= 1)
        fid = fopen(fileName,'w');            
        if (fid ~= -1)
          fprintf(fid,'/* '); 
          fprintf(fid, '%s', varargin{1});
          fprintf(fid, ' */ ');
          fclose(fid);                     
        end
    end;

    %Prepare filter data header
    dataHeader = [fsaver.savePlaneDataID, numberOfSets, dataSz(2)];
    
    %Prepare and write output data
    i = 1;
    outputRow(length(data(1,:))*numberOfSets + length(dataHeader) + 1) = 0;
    %Where 1 - control variable, number of elements in file
    for(n = 1:length(dataHeader))
       outputRow(i) = dataHeader(n);
       i = i + 1;
    end;
    
    for(n = 1:numberOfSets)
        for(m = 1:length(data(1,:)))
            outputRow(i) = data(n,m);
            i = i + 1;
        end;
    end;
    
    outputRow(i) = length(outputRow) - length(dataHeader) - 1;
    
    dlmwrite(fileName, outputRow, 'delimiter', ',', '-append', 'precision', fsaver.writePrecision);

end

