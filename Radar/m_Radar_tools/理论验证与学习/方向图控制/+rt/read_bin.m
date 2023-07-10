%--------------------------------------------------------------------------
%   rt toolbox
%   author:qwe14789cn@gmail.com
%   https://github.com/qwe14789cn/radar_tools
%--------------------------------------------------------------------------
%   [dataout] = rt.read_bin(file_name,file_type,mode_bl)
%--------------------------------------------------------------------------
%   Description:
%   read *.bin data.
%--------------------------------------------------------------------------
%   input:
%           file_name                  file name
%           file_type                  bin type (int8/uint16)
%           mode_bl                    read type big or little
%   output:
%           output                     output data
%--------------------------------------------------------------------------
%   Examples:   
%   rt.read_bin('1.bin','int8','b')
% ans =
%      1
%      2
%      3
%      4
%      5
%--------------------------------------------------------------------------
function [output] = read_bin(file_name,file_type,mode_bl)
if nargin == 2
    mode_bl = 'n';
end
f = fopen(file_name,'r');
output = fread(f,file_type,mode_bl);
fclose(f);