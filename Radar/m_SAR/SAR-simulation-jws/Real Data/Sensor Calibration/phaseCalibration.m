%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function sarDataOut = phaseCalibration(sarDataIn,iParams,fParams)
% Performs phase calibration and range bias calibration

%% Load Calibration Data

load('calData','calData','rangeBias_mm');

%% Declare k

f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
clear c f f0

%% Reshape the Input Data to the Proper Dimensionality

if ndims(sarDataIn) == 3
    sarDataIn = data3Dto4D(sarDataIn,iParams,fParams);
    input3D = true;
else
    input3D = false;
end

%% Perform Phase and Range Calibration
if iParams.CSAR
    calData = reshape(calData,1,1,[]);
    k = reshape(k,1,[]);
    if iParams.MIMO && iParams.nTx == 2
        rangeBiasCorrectionFactor = exp(1j*2*k*rangeBias_mm*1e-3);
        sarDataOut = calData.*sarDataIn.*rangeBiasCorrectionFactor;
    elseif iParams.nTx == 1
        rangeBiasCorrectionFactor = exp(1j*2*k*rangeBias_mm*1e-3);
        sarDataOut = calData(1:4).*sarDataIn.*rangeBiasCorrectionFactor;
    end
else
    calData = reshape(calData,[],1);
    k = reshape(k,1,1,1,[]);
    rangeBiasCorrectionFactor = exp(1j*2*k*rangeBias_mm*1e-3);
    sarDataOut = calData.*sarDataIn.*rangeBiasCorrectionFactor;
end

%% Reshape for Output
if input3D
    sarDataOut = data4Dto3D(sarDataOut,iParams,fParams);
end