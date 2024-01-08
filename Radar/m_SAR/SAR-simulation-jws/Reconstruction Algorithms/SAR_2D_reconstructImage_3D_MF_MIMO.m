%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [sarImage,xRangeT_m,yRangeT_m,zRangeT_m] = SAR_2D_reconstructImage_3D_MF_MIMO(sarData,iParams,fParams,p)
%% Input Arguments
%-------------------------------------------------------------------------%
% sarData: iParams.nVerMeasurement*iParams.nTx*iParams.nRx x iParams.nUsefulHorMeasurement x fParams.adcSample single, double, or gpuArray
% sarData: s(y,x,k)
%
% iParams: struct with fields
%   xStepM_mm           :   Step size of x-axis in mm
%   yStepM_mm           :   Step size of y-axis in mm
%   scanName            :   Name of the scan
%
% fParams: struct with fields
%   K                   :   Chrip Slope (Hz/s)
%   fS                  :   Sampling frequency (1/s)
%   adcSample           :   Number of samples
%   ADCStartTime        :   Time it takes to start sampling (s)
%   f0                  :   Chirp start frequency (Hz)
%
% p: struct with fields
%   xT                  :   x-axis of target domain
%   yT                  :   y-axis of target domain
%   zT                  :   z-axis of target domain

%% Declare Optional Parameters
%-------------------------------------------------------------------------%
if ~isfield(iParams,'isAmplitudeFactor')
    iParams.isAmplitudeFactor = true;
end

%% Declare Wavenumber Vectors
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = reshape(k,1,1,1,[]);
clear c f f0

sarData = permute(sarData,[1,2,4,3]);

%% Define Target Range Domain
%-------------------------------------------------------------------------%
% xRangeT_m = reshape(p.xT(1):iParams.xStepM*1e-3:p.xT(end),1,[],1);
xRangeT_m = reshape((-iParams.nFFT/2:iParams.nFFT/2-1)*iParams.xStepM_mm*1e-3,1,[],1);
% yRangeT_m = reshape(p.yT(1):iParams.yStepM*1e-3:p.yT(end),[],1,1);
yRangeT_m = reshape((-iParams.nFFT/2:iParams.nFFT/2-1)*iParams.yStepM_mm*1e-3,[],1,1);
zRangeT_m = reshape(p.zT,1,1,[]);

%% Define the Convolutional Kernel and its FFT
%-------------------------------------------------------------------------%
if iParams.isAmplitudeFactor
    convKernel = (xRangeT_m.^2 + yRangeT_m.^2 + zRangeT_m.^2).*exp(-1j*2*k.*sqrt(xRangeT_m.^2 + yRangeT_m.^2 + zRangeT_m.^2));
else
    convKernel = exp(-1j*2*k.*sqrt(xRangeT_m.^2 + yRangeT_m.^2 + zRangeT_m.^2));
end

%% Ensure nFFT is Large Enough
%-------------------------------------------------------------------------%
if iParams.nFFT < iParams.nUsefulHorMeasurement
    warning("iParams.nFFT is smaller than iParams.nUsefulHorMeasurement, increasing iParams.nFFT")
    iParams.nFFT = 2^(ceil(log2(iParams.nUsefulHorMeasurement)));
end
if iParams.nFFT < iParams.nVerMeasurement
    warning("iParams.nFFT is smaller than iParams.nVerMeasurement, increasing iParams.nFFT")
    iParams.nFFT = 2^(ceil(log2(iParams.nVerMeasurement)));
end
if iParams.nFFT < numel(xRangeT_m)
    warning("iParams.nFFT is smaller than length of x, increasing iParams.nFFT")
    iParams.nFFT = 2^(ceil(log2(numel(xRangeT_m))));
end
if iParams.nFFT < numel(yRangeT_m)
    warning("iParams.nFFT is smaller than length of y, increasing iParams.nFFT")
    iParams.nFFT = 2^(ceil(log2(numel(yRangeT_m))));
end

%% Zero-pad x-domain of sarData and convKernel
%-------------------------------------------------------------------------%
if (iParams.nFFT > iParams.nUsefulHorMeasurement)
    sarData = padarray(sarData,[0 floor((iParams.nFFT-iParams.nUsefulHorMeasurement)/2)],0,'pre');
    sarData = padarray(sarData,[0 ceil((iParams.nFFT-iParams.nUsefulHorMeasurement)/2)],0,'post');
end
if (iParams.nFFT > iParams.nVerMeasurement)
    sarData = padarray(sarData,[floor((iParams.nFFT-iParams.nUsefulHorMeasurement)/2) 0],0,'pre');
    sarData = padarray(sarData,[ceil((iParams.nFFT-iParams.nUsefulHorMeasurement)/2) 0],0,'post');
end
if(iParams.nFFT > numel(xRangeT_m))
    convKernel = padarray(convKernel,[0 floor((iParams.nFFT - numel(xRangeT_m))/2)],0,'pre');
    convKernel = padarray(convKernel,[0 ceil((iParams.nFFT - numel(xRangeT_m))/2)],0,'post');
end
if(iParams.nFFT > numel(yRangeT_m))
    convKernel = padarray(convKernel,[floor((iParams.nFFT - numel(xRangeT_m))/2) 0],0,'pre');
    convKernel = padarray(convKernel,[ceil((iParams.nFFT - numel(xRangeT_m))/2) 0],0,'post');
end

%% Take an FFT Across the x-domain of the sarData and convKernel
%-------------------------------------------------------------------------%
sarDataFFT = fft2(sarData,iParams.nFFT,iParams.nFFT);
convKernelFFT = fft2(convKernel,iParams.nFFT,iParams.nFFT);

%% Recover sarImage: p(y,x,z) by Convolution Properties of FFT
%-------------------------------------------------------------------------%
sarImage = ifft2( sum(sarDataFFT .* convKernelFFT,4),iParams.nFFT,iParams.nFFT);

%% Display Result
%-------------------------------------------------------------------------%
volumeViewer(abs(sarImage));