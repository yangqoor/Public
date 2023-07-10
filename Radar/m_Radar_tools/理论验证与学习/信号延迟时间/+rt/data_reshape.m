%--------------------------------------------------------------------------
%   rt toolbox
%   author:qwe14789cn@gmail.com
%   https://github.com/qwe14789cn/radar_tools
%--------------------------------------------------------------------------
%   [dataout] = rt.data_reshape(datain,data_size)
%--------------------------------------------------------------------------
%   Description:
%   along the Column cut the data to the set size
%--------------------------------------------------------------------------
%   input:
%           datain                  input data
%           data_size               reshape size
%   output:
%           dataout                 output data
%--------------------------------------------------------------------------
%   Examples:
%   a = [1 2 3 4 5 6 7 8 9 10];
%   rt.data_reshape(a,2)
%   ans =
%     1     3     5     7     9
%     2     4     6     8    10
%   rt.data_reshape(a,[2 2])
%   ans(:,:,1) =
%     1     3
%     2     4
%   ans(:,:,2) =
%     5     7
%     6     8
%--------------------------------------------------------------------------
function [dataout] = data_reshape(datain,data_size)
datain = datain(:);
if length(data_size)==2
    level = floor(size(datain,1)/(data_size(1)*data_size(2)));              %�ȼ�����Եõ����ٸ�CPI����
    datain = datain(1:data_size(1)*data_size(2)*level,:);                   %�����и�����
    dataout = reshape(datain,data_size(1),data_size(2),level);              %�����޸���״
    
elseif length(data_size)==1
    level = floor(size(datain,1)/(data_size(1)));                           %�ȼ�����Եõ����ٸ�CPI����
    datain = datain(1:data_size(1)*level,:);                                %�����и�����
    dataout = reshape(datain,data_size(1),level);                           %�����޸���״
end
