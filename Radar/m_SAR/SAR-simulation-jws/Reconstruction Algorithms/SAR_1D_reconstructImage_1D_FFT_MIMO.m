%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [sarImage,yRangeT_m] = SAR_1D_reconstructImage_1D_FFT_MIMO(sarData,iParams,fParams)
% Reconstructs a 1D image from SAR echo data using the FFT-based technique.
% Expects a 1D scan across the y-axis using a MIMO transceiver.

%% Input Arguments
%-------------------------------------------------------------------------%
% sarData: iParams.nMeasurement x fParams.adcSample single, double, or gpuArray
%
% iParams: struct with fields
%   z0_mm               :   Distance of target
%   nVerMeasurement     :   Number of vertical captures (each capture contains 8 channels)
%   yStepM_mm           :   Step size of y-axis in mm
%   scanName            :   Name of the scan
%
% fParams: struct with fields
%   K                   :   Chrip Slope (Hz/s)
%   fS                  :   Sampling frequency (1/s)
%   adcSample           :   Number of samples
%   ADCStartTime        :   Time it takes to start sampling (s)
%   f0                  :   Chirp start frequency (Hz)

%% Declare Wavenumber Vector
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = reshape(k,1,[]);
clear c f f0

[iParams.nMeasurement,fParams.adcSample] = size(sarData);

ksY = 2*pi/(iParams.yStepM_mm*1e-3);

kY = reshape(linspace(-ksY/2,ksY/2,iParams.nFFT),[],1);

kZ = sqrt(4*k.^2 - kY.^2);

%% Reconstruct Image
%-------------------------------------------------------------------------%
phaseFactor = exp(-1j.*kZ.*iParams.z0_mm*1e-3);
phaseFactor( (kY.^2) > 4*k.^2 ) = 0;

amplitudeFactor = kZ;
amplitudeFactor( (kY.^2) > 4*k.^2 ) = 0;

sarDataPadded = sarData;
if (iParams.nFFT > size(sarData,1))
    sarDataPadded = padarray(sarDataPadded,[floor((iParams.nFFT-size(sarData,1))/2) 0],0,'pre');
    sarDataPadded = padarray(sarDataPadded,[ceil((iParams.nFFT-size(sarData,1))/2) 0],0,'post');
end

sarImage = trapz(squeeze(k),ifft( fftshift(fft(sarDataPadded,iParams.nFFT,1),1)/iParams.nFFT .* amplitudeFactor .* phaseFactor,[],1),2);

%% Plot the Reconstructed Image
%-------------------------------------------------------------------------%
yRangeT_m = iParams.yStepM_mm*1e-3*(-(iParams.nFFT-1)/2 : (iParams.nFFT-1)/2);

figure('OuterPosition',[350 150 670*2 712]);
subplot(121)
plot(yRangeT_m,abs(sarImage))
xlabel("y (m)")
title(iParams.scanName + " SAR 1D Image - " + iParams.z0_mm + "mm Focused")
subplot(122)

sarImageLog = mag2db(abs(sarImage));
sarImageLog = sarImageLog - max(sarImageLog(:));
plot(yRangeT_m,sarImageLog)
xlabel("y (m)")
ylabel("dB");
title(iParams.scanName + " SAR 1D Image - " + iParams.z0_mm + "mm Focused")