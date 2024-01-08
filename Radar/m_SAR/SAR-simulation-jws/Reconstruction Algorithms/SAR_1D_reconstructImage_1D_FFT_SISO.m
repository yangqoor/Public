%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [sarImage,xRangeT_m] = SAR_1D_reconstructImage_1D_FFT_SISO(sarData,iParams,fParams)
% Reconstructs a 1D image from SAR echo data using the FFT-based technique.
% Expects a 1D scan across the x-axis using a SISO transceiver.

%% Input Arguments
%-------------------------------------------------------------------------%
% sarData: iParams.nUsefulHorMeasurement x fParams.adcSample single, double, or gpuArray
%
% iParams: struct with fields
%   z0_mm               :   Distance of target
%   xStepM_mm           :   Step size of x-axis in mm
%   scanName            :   Name of the scan
%   xU                  :   Upsample factor for x-axis
%
% fParams: struct with fields
%   K                   :   Chrip Slope (Hz/s)
%   fS                  :   Sampling frequency (1/s)
%   adcSample           :   Number of samples
%   ADCStartTime        :   Time it takes to start sampling (s)
%   f0                  :   Chirp start frequency (Hz)

%% Declare Optional Parameters
%-------------------------------------------------------------------------%
if ~isfield(iParams,'kU')
    iParams.kU = 1;
end
if ~isfield(iParams,'xU')
    iParams.xU = 1;
end

%% Declare Wavenumber Vector
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = reshape(k,1,[]);
clear c f f0

%% Upsample x and k
%-------------------------------------------------------------------------%
if iParams.kU > 1
    kUpsample = reshape(linspace(min(k),max(k),iParams.kU*length(k)),1,[]);
    sarDatatemp = sarData;
    sarData = zeros([size(sarData,1),length(kUpsample)]);
    if ~isempty(gcp('nocreate'))
        parfor iX = 1:size(sarData,1)
            sarData(iX,:) = interp1(k,sarDatatemp(iX,:),kUpsample);
        end
    else
        for iX = 1:size(sarData,1)
            sarData(iX,:) = interp1(k,sarDatatemp(iX,:),kUpsample);
        end
    end
    k = kUpsample;
    clear sarDatatemp kUpsample
end
if iParams.xU > 1
    sarData = upsample(sarData,iParams.xU);
    iParams.xStepM_mm = iParams.xStepM_mm/iParams.xU;
end

%% Zeropad sarData to Center
%-------------------------------------------------------------------------%
sarDataPadded = sarData;
if (iParams.nFFT > size(sarData,1))
    sarDataPadded = padarray(sarDataPadded,[floor((iParams.nFFT-size(sarData,1))/2) 0],0,'pre');
    sarDataPadded = padarray(sarDataPadded,[ceil((iParams.nFFT-size(sarData,1))/2) 0],0,'post');
else
    iParams.nFFT = size(sarData,1);
end

%% Compute Phase Factor and Amplitude Factor
%-------------------------------------------------------------------------%
ksX = 2*pi/(iParams.xStepM_mm*1e-3);
kX = reshape(linspace(-ksX/2,ksX/2,iParams.nFFT),[],1);
kZ = sqrt(4*k.^2 - kX.^2);

phaseFactor = exp(-1j.*kZ.*iParams.z0_mm*1e-3);
phaseFactor( (kX.^2) > 4*k.^2 ) = 0;

amplitudeFactor = kZ;
amplitudeFactor( (kX.^2) > 4*k.^2 ) = 0;

%% Reconstruct Image by FFT Method
%-------------------------------------------------------------------------%
sarImage = trapz(squeeze(k),ifft( fftshift(fft(sarDataPadded,[],1),1) .* amplitudeFactor .* phaseFactor,[],1),2);

%% Display the Reconstructed Image
%-------------------------------------------------------------------------%
xRangeT_m = iParams.xStepM_mm*1e-3*(-(iParams.nFFT-1)/2 : (iParams.nFFT-1)/2);

figure('OuterPosition',[350 150 670*2 712]);
subplot(121)
plot(xRangeT_m,abs(sarImage))
xlabel("x (m)")
title(iParams.scanName + " SAR 1D Image - " + iParams.z0_mm + "mm Focused")
subplot(122)

sarImageLog = mag2db(abs(sarImage));
sarImageLog = sarImageLog - max(sarImageLog(:));
plot(xRangeT_m,sarImageLog)
xlabel("x (mm)")
ylabel("dB");
title(iParams.scanName + " SAR 1D Image - " + iParams.z0_mm + "mm Focused")