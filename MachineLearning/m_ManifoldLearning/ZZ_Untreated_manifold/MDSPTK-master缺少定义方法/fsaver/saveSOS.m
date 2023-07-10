%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FileName:        saveSOS.m
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
function saveSOS( fileName, gain, sos, order, numberOfSets, varargin )
%SAVESOS Summary of this function goes here
%   Detailed explanation goes here

   %Parse description
   if(nargin > 5 && strcmp(varargin{1}, '') ~= 1)
       description = varargin{1};
   else
       description = '';
   end;
   
    %Save all
    if(numberOfSets == 1)
        saveSOSSingleSet(fileName, gain, sos, order, description);
    else
        saveSOSMultipleSets(fileName, gain, sos, order, numberOfSets, description);
    end;
    
end

function saveSOSSingleSet( fileName, gain, sos, order, description )
    
   numberOfCoefsInSOS = 6;

   %Number of coefficients in single SOS * number of sections for
   %appropriate order + gain coefficient
   numberOfCoefsInSet = numberOfCoefsInSOS*ceil(order/2) + 1;

    %Gain
    if(length(gain) ~= 1)
        error('Number of gain coefs must be equal numberOfSets');
    end;

    %Rotate if needed
    mxsz = size(sos);
    if(mxsz(2) ~= numberOfCoefsInSOS)
        sos = rot90(sos);
    end;

    %Check order
    if((2*mxsz(2) ~= order) && (2*mxsz(2) ~= order + 1))
        error('Sos matrix sizes inappropriate for filter order');
    end;

    %Save data to file
    %Add description if provided
    if(strcmp(description, '') ~= 1)
        fid = fopen(fileName,'w');            
        if (fid ~= -1)
          fprintf(fid,'/* '); 
          fprintf(fid, '%s', description);
          fprintf(fid, ' */ ');
          fclose(fid);                     
        end
    end;

    %Prepare filter data header
    dataHeader = [fsaver.saveSOSID, numberOfSets, numberOfCoefsInSet];

    %Prepare and write output data
    outputRow(numberOfCoefsInSet + length(dataHeader) + 1) = 0;
    %Where 1 - control variable, number of elements in file
    i = 1;
    for(n = 1:length(dataHeader))
       outputRow(i) = dataHeader(n);
       i = i + 1;
    end;

    for(n = 1:mxsz(2))
        for(k = 1:numberOfCoefsInSOS)
            outputRow(i) = sos(n,k);
            i = i + 1;
        end;
    end;

    %Write number of coefficients without last for checking at C-code side
    outputRow(i) = length(outputRow) - length(dataHeader) - 1;

    dlmwrite(fileName, outputRow, 'delimiter', ',', '-append', 'precision', fsaver.writePrecision);
        
end

function saveSOSMultipleSets(fileName, gain, sos, order, numberOfSets, description)
    
    numberOfCoefsInSOS = 6;

    %Number of coefficients in single SOS * number of sections for
    %appropriate order + gain coefficient
    numberOfCoefsInSet = numberOfCoefsInSOS*ceil(order/2) + 1;

    %Check gain
    if(length(gain) ~= numberOfSets)
        error('Number of gain coefs must be equal numberOfSets');
    end;
   
    %Check 3D matrix sizes
    mxsz = size(sos);
    if(length(mxsz) ~= 3)
        error('coefs matrix must have 3 dementions: coefs sets number x number of SOS in set x 6 (number of coefs in SOS)');
    elseif(mxsz(1) ~= numberOfSets || (2*mxsz(2) ~= order) && (2*mxsz(2) ~= order + 1) || mxsz(3) ~= 6)
        error('SOS coefs matrix must be 3D and have next structure: coefs sets number x number of SOS in set x 6 (number of coefs in SOS)');
    end;
    
    %Save data to file
    %Add description if provided
    if(strcmp(description, '') ~= 1)
        fid = fopen(fileName,'w');            
        if (fid ~= -1)
          fprintf(fid,'/* '); 
          fprintf(fid, '%s', description);
          fprintf(fid, ' */ ');
          fclose(fid);                     
        end
    end;
    
    %Prepare filter data header
    dataHeader = [fsaver.saveSOSID, numberOfSets, numberOfCoefsInSet];
  
    %Prepare and write output data
    outputRow(numberOfCoefsInSet*numberOfSets + length(dataHeader) + 1) = 0;
    %Where 1 - control variable, number of elements in file
    i = 1;
    for(n = 1:length(dataHeader))
       outputRow(i) = dataHeader(n);
       i = i + 1;
    end;

    for(p = 1:numberOfSets)
        %Write gain coef
        outputRow(i) = gain(p);
        i = i + 1;
        for(n = 1:mxsz(2))
            for(k = 1:numberOfCoefsInSOS)
                outputRow(i) = sos(p,n,k);
                i = i + 1;
            end;
        end;
    end;

    %Write number of coefficients without last for checking at C-code side
    outputRow(i) = length(outputRow) - length(dataHeader) - 1;
   
    dlmwrite(fileName, outputRow, 'delimiter', ',', '-append', 'precision', fsaver.writePrecision);
    
end

