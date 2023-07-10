%--------------------------------------------------------------------------
%   [dataout] = data_reshape(datain,data_size��flag)
%--------------------------------------------------------------------------
%   ����:
%   �����з����������ݸ�ʽ�������β���е�������0(matlab��reshape�޷���β��)
%--------------------------------------------------------------------------
%   ����:
%           datain                  ��������
%           data_size               �µĸ�ʽ��̬,֧��1ά�Ͷ�ά([x]����[x y])
%           flag                    0Ĭ�� ��β��1��0
%   ���:
%           dataout                 �����������
%--------------------------------------------------------------------------
%   ����:
%   a = [1 2 3 4 5 6 7 8 9 10 11];
%   data_reshape(a,2)
%   ans =
%     1     3     5     7     9
%     2     4     6     8    10
%   data_reshape(a,2,1)
%   ans =
%      1     3     5     7     9    11
%      2     4     6     8    10     0
%   data_reshape(a,[2 3],1)
%   ans(:,:,1) =
%      1     3     5
%      2     4     6
%   ans(:,:,2) =
%      7     9    11
%      8    10     0
%--------------------------------------------------------------------------
function [dataout] = data_reshape(datain,data_size,flag)
if nargin==2
    flag = 0;
elseif nargin == 3
    flag = flag;
end
datain = datain(:);
if length(data_size)==2
    level = floor(size(datain,1)/(data_size(1)*data_size(2)));              %�ȼ�����Եõ����ٸ�CPI����
    rest = datain(data_size(1)*data_size(2)*level+1:end,:);
    datain = datain(1:data_size(1)*data_size(2)*level,:);                   %�����и�����
    dataout = reshape(datain,data_size(1),data_size(2),level);              %�����޸���״
    if flag == 1
        dataout(:,:,size(dataout,3)+1) = ...
            reshape([rest;zeros(data_size(1)*data_size(2) - ...
            numel(rest),1)],data_size);                                     %�����޸���״ ��0
    end
elseif length(data_size)==1
    level = floor(size(datain,1)/(data_size(1)));                           %�ȼ�����Եõ����ٸ�CPI����
    rest = datain(data_size(1)*level+1:end,:);
    datain = datain(1:data_size(1)*level,:);                                %�����и�����
    dataout = reshape(datain,data_size(1),level);                           %�����޸���״ ����0
    if flag == 1                 
        dataout = [dataout [rest;zeros(data_size(1)-numel(rest),1)]];       %�����޸���״ ��0
    end
end
