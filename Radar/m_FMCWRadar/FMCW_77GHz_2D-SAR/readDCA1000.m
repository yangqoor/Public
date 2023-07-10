%%% This script is used to read the binary file produced by the DCA1000
%%% �˽ű����ڶ�ȡDCA1000��Mmwave Studio���ɵĶ������ļ�
%%% and Mmwave Studio
function [retVal, raw_data] = readDCA1000(fileName)
%% global variables
% change based on sensor config
% ���ݴ��������ý��и���
numADCBits = 16; % number of ADC bits per sample ÿ��������ADCλ��
numLanes = 4; % do not change. number of lanes is always 4 even if only 1 lane is used. unused lanes
% ��Ҫ�ı䡣������ʼ��Ϊ4����ʹ��ʹ��1��������δʹ�ó���
isReal = 0; % set to 1 if real only data, 0 if complex dataare populated with 0 %% read file and convert to signed number
% ����Ǵ�ʵ�����ݣ�������Ϊ1�������0%%��ȡ�ļ���临�����ݲ�ת��Ϊ�з�������������Ϊ0
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
