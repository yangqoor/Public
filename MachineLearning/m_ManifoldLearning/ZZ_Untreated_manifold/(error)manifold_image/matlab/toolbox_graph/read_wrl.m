function [vertex, face] = read_wrl(filename)

% read_wrl - load a mesh from a VRML file
%
%   [vertex, face] = read_wrl(filename);
%
%   Copyright (c) 2004 Gabriel Peyré

fp = fopen(filename,'r');
if fp == -1
    fclose all;
    str = sprintf('Cannot open file %s \n',filename);
    errordlg(str);
    error(str);
end

tempstr = ' ';

key = 'point [';
vertex = [];

while ( tempstr ~= -1)
    tempstr = fgets(fp);   % -1 if eof
    if( ~isempty(findstr(tempstr,key)) )
        nc = 3;
        while nc>0
            tempstr = fgets(fp);   % -1 if eof
            [cvals,nc] = sscanf(tempstr,'%f %f %f,');
            if nc>0
                if mod(nc,3)~=0
                    error('Not correct WRL format');
                end
                vertex = [vertex, reshape(cvals, 3, nc/3)];
            end
        end
        break;
    end
end

if nargout==1
    return;
end

key = 'coordIndex [';
face = [];

while ( tempstr ~= -1)
    tempstr = fgets(fp);   % -1 if eof
    if( ~isempty(findstr(tempstr,key)) )
        nc = 3;
        while nc>0
            tempstr = fgets(fp);   % -1 if eof
            [cvals,nc] = sscanf(tempstr,'%d %d %d -1,');
            if nc==0 || mod(nc,3)~=0
                [cvals,nc] = sscanf(tempstr,'%d, %d, %d, -1,');
            end
            if nc>0
                face = [face, reshape(cvals, 3, nc/3)+1];
            end
        end
        fclose(fp);
        return;
    end
end