%% Copyright(C) 2018 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function rawData4D = dataReadTSW(iParams,fParams)
%% Declare Optional Parameters

if ~isfield(iParams,'isTwoDirectionScanning')
    iParams.isTwoDirectionScanning = false;
end

%% Read from Bin File
fileID = fopen(iParams.scanName + ".bin",'r');
% q = quantizer('double', 'Round', 'Saturate', [16  15]);
% rawData = bin2num(q,rawData);

rawData4D = fread(fileID,'uint16','l'); % for all data at the same time
rawData4D = rawData4D - 2^15;

%% Set default parameters

if iParams.CSAR
    iParams.nUsefulHorMeasurement = iParams.nAngMeasurement; % number of total measurements
end
iParams.nMeasurement = iParams.nUsefulHorMeasurement*iParams.nVerMeasurement; % number of total measurements

%% Reshape Row Data and Calculate Complex Row Data

rawData4D = reshape(rawData4D,2*iParams.nRx,[]);
rawData4D = rawData4D([1,3,5,7],:) + 1i*rawData4D([2,4,6,8],:);

%% Reshape Row Data Accordingly
try
    rawData4D = squeeze(reshape(rawData4D,iParams.nRx,fParams.adcSample,iParams.nTx,1,1,iParams.nMeasurement));
catch
    warning("Something is wrong with the number of captures!")
    fclose(fileID);
    return;
end

fclose(fileID);

%% Create Virtual Array
if iParams.nTx > 1
    rawData4D = reshape(permute(rawData4D,[1,3,2,4]),iParams.nRx*iParams.nTx,fParams.adcSample,iParams.nMeasurement);
end

%% Rearrange rawData if it is obtained after fast processing scanning scenario
rawData4D = reshape(rawData4D,iParams.nTx*iParams.nRx,fParams.adcSample,iParams.nUsefulHorMeasurement,iParams.nVerMeasurement);
if iParams.isTwoDirectionScanning
    for n = 1:iParams.nVerMeasurement
        % reverse all even vertical scans
        if rem(n-1,2)
            rawData4D(:,:,:,n) = flip(rawData4D(:,:,:,n),3);
        end
    end
end

rawData4D = reshape(rawData4D,iParams.nTx*iParams.nRx,fParams.adcSample,[]);

%% Reshape Row Data for Old 3D FFT Proessing
rawData4D = reshape(rawData4D,iParams.nTx*iParams.nRx,fParams.adcSample,iParams.nUsefulHorMeasurement,iParams.nVerMeasurement);

%% Reshape Row Data for Analytical FFT Proessing
if iParams.CSAR
    % rawData3D = s(theta,k,nTx*nRx,y)
    rawData4D = permute(rawData4D,[3,2,1,4]);
else
    % rawData3D = s(nTx*nRx,y,x,k)
    rawData4D = permute(rawData4D,[1,4,3,2]);
end

end %% End of data Read