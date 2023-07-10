
%% 1.数据采集与读取
%%% This script is used to read the binary file produced by the DCA1000
%%% and Mmwave Studio
%%% Command to run in Matlab GUI -readDCA1000('<ADC capture bin file>') 

function [retVal] = readDCA1000(fileName,numADCSamples,numRX)

% global variables
                       % change based on sensor config
numADCBits = 16;       % number of ADC bits per sample
numLanes = 2;          % do not change. number of lanes is always 2
isReal = 0;            % set to 1 if real only data, 0 if complex data0

%% read file
% read .bin file

fid = fopen(fileName,'r');
adcData = fread(fid, 'int16');

% if 12 or 14 bits ADC per sample compensate for sign extension

if numADCBits ~= 16
    l_max = 2^(numADCBits-1)-1;
    adcData(adcData > l_max) = adcData(adcData > l_max) - 2^numADCBits;
end

fclose(fid);

fileSize = size(adcData, 1);

% real data reshape, filesize = numADCSamples*numChirps

if isReal
    numChirps = fileSize/numADCSamples/numRX;
    LVDS = zeros(1, fileSize);
    %create column for each chirp
    LVDS = reshape(adcData, numADCSamples*numRX, numChirps);
    %each row is data from one chirp
    LVDS = LVDS.';
else
% for complex data
% filesize = 2 * numADCSamples*numChirps

    numChirps = fileSize/2/numADCSamples/numRX;
    LVDS = zeros(1, fileSize/2);
    
    %combine real and imaginary part into complex data
    %read in file: 2I is followed by 2Q
    
    counter = 1;
    for i=1:4:fileSize-1
        LVDS(1,counter) = adcData(i) + sqrt(-...
        1)*adcData(i+2); LVDS(1,counter+1) = adcData(i+1)+sqrt(-...
        1)*adcData(i+3); counter = counter + 2;
    end
    % create column for each chirp
    
    LVDS = reshape(LVDS, numADCSamples*numRX*3, numChirps/3);
    
    %each row is data from one chirp
    
    LVDS = LVDS.';            % 8192*3072
end

%organize data per RX

adcData = zeros(numRX*3,numChirps/3*numADCSamples);

for row = 1:numRX*3             %4个
    for i = 1: numChirps/3      %总帧的脉冲的点数 96*256=24576个
        adcData(row, (i-1)*numADCSamples+1:i*numADCSamples) = LVDS(i, (row-1)*numADCSamples+1:row*numADCSamples);
    end
end
% return receiver data

 retVal = adcData;
% retVal1 = retVal(1,:);%接受天线1
% retVal2 = retVal(2,:);%接受天线2
% retVal3 = retVal(3,:);%接受天线3
% retVal4 = retVal(4,:);%接受天线4
% 
%  retVal1 

end
