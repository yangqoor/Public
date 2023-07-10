%%% This script is used to read the binary file produced by the DCA1000
%%% 此脚本用于读取DCA1000和Mmwave Studio生成的二进制文件
%%% and Mmwave Studio
function [retVal, raw_data] = readDCA1000(fileName)
%% global variables
% change based on sensor config
% 根据传感器配置进行更改
numADCBits = 16; % number of ADC bits per sample 每个采样的ADC位数
numLanes = 4; % do not change. number of lanes is always 4 even if only 1 lane is used. unused lanes
% 不要改变。车道数始终为4，即使仅使用1条车道。未使用车道
isReal = 0; % set to 1 if real only data, 0 if complex dataare populated with 0 %% read file and convert to signed number
% 如果是纯实数数据，则设置为1；如果用0%%读取文件填充复杂数据并转换为有符号数，则设置为0
% read .bin file
fid = fopen(fileName,'r');
% DCA1000 should read in two's complement data
adcData = fread(fid, 'int16');
adcData = adcData(:,1);
% if 12 or 14 bits ADC per sample compensate for sign extension
if numADCBits ~= 16
l_max = 2^(numADCBits-1)-1;
adcData(adcData > l_max) = adcData(adcData > l_max) - 2^numADCBits;
end
fclose(fid);
%% organize data by LVDS lane
% for real only data
if isReal
% reshape data based on one samples per LVDS lane
adcData = reshape(adcData, numLanes, []);
%for complex data
else
% reshape and combine real and imaginary parts of complex number
adcData = reshape(adcData, numLanes*2, []);
adcData = adcData([1,2,3,4],:) + sqrt(-1)*adcData([5,6,7,8],:);
end
%% return receiver data
retVal = adcData;
for i=1:407
    for j =1:512
        raw_data(i,j)=adcData(1,j+(i-1)*512);
    end
end
