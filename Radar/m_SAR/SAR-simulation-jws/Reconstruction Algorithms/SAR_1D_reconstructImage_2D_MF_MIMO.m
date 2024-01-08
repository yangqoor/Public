%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function sarImage = SAR_1D_reconstructImage_2D_MF_MIMO(sarDataY,iParams,fParams,p)
% Reconstructs a 2D image from SAR echo data using the matched filter back
% projection (MF) technique. This method repeats the back projection
% algorithm using a matched filter and Fourier transform identities to
% simplify the BPA and reduce the computational expense. Expects a 1D scan
% across the y-axis using a MIMO transceiver.

%% Input Arguments
%-------------------------------------------------------------------------%
% sarData: iParams.nTx*iParams.nRx*iParams.nVerMeasurement x fParams.adcSample single, double, or gpuArray
%
% iParams: struct with fields
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
%   yT                  :   y-axis of target domain
%   zT                  :   z-axis of target domain

%% Define Optional Parameters
%-------------------------------------------------------------------------%
if ~isfield(iParams,'isAmplitudeFactor')
    iParams.isAmplitudeFactor = true;
end

tic

%% Declare Wavenumber Vector
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = reshape(k,1,[]);
clear c f f0

%% Define Target Range Domain
%-------------------------------------------------------------------------%
% Constraint on x: needs to have the same spaceing as xM, that is
yRangeT_m = (1:iParams.nFFT)*iParams.yStepM_mm*1e-3;
if mod(iParams.nUsefulHorMeasurement,2) == 0
    yRangeT_m = yRangeT_m - yRangeT_m(end/2);
else
    yRangeT_m = yRangeT_m - yRangeT_m( (end+1)/2 );
end
yRangeT_m = reshape(yRangeT_m,[],1);
zRangeT_m = reshape(p.zT,1,1,[]);

%% Define the convolutional kernel and its FFT
%-------------------------------------------------------------------------%
if iParams.isAmplitudeFactor
    convKernel = (yRangeT_m.^2 + zRangeT_m.^2).*exp(-1j*2*k.*sqrt(yRangeT_m.^2 + zRangeT_m.^2));
else
    convKernel = exp(-1j*2*k.*sqrt(yRangeT_m.^2 + zRangeT_m.^2));
end

%% Ensure iParams.nFFT is Large Enough
%-------------------------------------------------------------------------%
if iParams.nFFT < iParams.nUsefulHorMeasurement
    warning("iParams.nFFT is smaller than iParams.nUsefulHorMeasurement, increasing iParams.nFFT")
    iParams.nFFT = 2^(ceil(log2(iParams.nUsefulHorMeasurement)));
end
if iParams.nFFT < numel(yRangeT_m)
    warning("iParams.nFFT is smaller than length of x, increasing iParams.nFFT")
    iParams.nFFT = 2^(ceil(log2(numel(yRangeT_m))));
end

%% Zero-pad x-domain of sarData and convKernel
%-------------------------------------------------------------------------%
if (iParams.nFFT > iParams.nUsefulHorMeasurement)
    sarDataY = padarray(sarDataY,[floor((iParams.nFFT-iParams.nUsefulHorMeasurement)/2) 0],0,'pre');
    sarDataY = padarray(sarDataY,[ceil((iParams.nFFT-iParams.nUsefulHorMeasurement)/2) 0],0,'post');
end
if(iParams.nFFT > numel(yRangeT_m))
    convKernel = padarray(convKernel,[floor((iParams.nFFT - numel(yRangeT_m))/2) 0],0,'pre');
    convKernel = padarray(convKernel,[ceil((iParams.nFFT - numel(yRangeT_m))/2) 0],0,'post');
end

%% Take an FFT across the x dimension of the sarData and convKernel
%-------------------------------------------------------------------------%
sarDataFFT = fft(sarDataY,iParams.nFFT,1);
convKernelFFT = fft(convKernel,iParams.nFFT,1);

%% Reconstruct Image
%-------------------------------------------------------------------------%
sarImage = squeeze(ifftshift(ifft( sum(sarDataFFT .* convKernelFFT,2),iParams.nFFT,1),1));
clear sarDataFFT convKernelFFT convKernel

disp("Completed 2D MIMO MF in " + toc + " seconds");

%% Display the Reconstructed Image
%-------------------------------------------------------------------------%
yRangeT_m = round(reshape(yRangeT_m,[],1) + iParams.yStepM_mm*1e-3,5);
zRangeT_m = reshape(zRangeT_m,1,[]);

figure('OuterPosition',[350 150 670*2 712]);
subplot(121)
mesh(zRangeT_m,yRangeT_m,abs(sarImage),'FaceColor','interp','LineStyle','none')
view(2)
xlim([zRangeT_m(1) zRangeT_m(end)])
ylim([yRangeT_m(1) yRangeT_m(end)])
xlabel("z (m)")
ylabel("y (m)")
title(iParams.scanName + " SAR 2D Image using Matched Filter-BPA")

sarImageLog = mag2db(abs(sarImage));
sarImageLog = sarImageLog - max(sarImageLog(:));
sarImageLog(sarImageLog < -100) = -100;
subplot(122)
mesh(zRangeT_m,yRangeT_m,sarImageLog,'FaceColor','interp','LineStyle','none')
xlabel("z (m)")
ylabel("y (m)")
zlabel("dB")
xlim([zRangeT_m(1) zRangeT_m(end)])
ylim([yRangeT_m(1) yRangeT_m(end)])
zlim([-100 0])
title(iParams.scanName + " SAR 2D Log Image using Matched Filter-BPA")