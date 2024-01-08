%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [sarImage,xRangeT_m,zRangeT_m] = SAR_1D_reconstructImage_2D_RMA_SISO(sarData,iParams,fParams)
% Reconstructs a 2D image from SAR echo data using the range migration
% algorithm (RMA). Expects a 1D scan across the x-axis using a SISO
% tranceiver. Upsampling in the z-axis/k-domain does not appear to impact
% image quality.

%% Input Arguments
%-------------------------------------------------------------------------%
% sarData: iParams.nUsefulHorMeasurement x fParams.adcSample single, double, or gpuArray
%
% iParams: struct with fields
%   z0_mm               :   Distance of target
%   xStepM_mm           :   Step size of x-axis in mm
%   scanName            :   Name of the scan
%   zU                  :   Upsample factor for z-axis/k-domain
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
if ~isfield(iParams,'zU')
    iParams.zU = 1;
end
if ~isfield(iParams,'xU')
    iParams.xU = 1;
end
if ~isfield(iParams,"Stolt")
    iParams.Stolt = "linear";
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
if iParams.zU > 1
    kUpsample = reshape(linspace(min(k),max(k),iParams.zU*length(k)),1,[]);
    sarDatatemp = sarData;
    sarData = zeros([size(sarData,1),length(kUpsample)]);
    for iX = 1:size(sarData,1)
        sarData(iX,:) = interp1(k,sarDatatemp(iX,:),kUpsample);
    end
    k = kUpsample;
    clear sarDatatemp kUpsample iX
end
if iParams.xU > 1
    sarData = upsample(sarData,iParams.xU);
    iParams.xStepM_mm = iParams.xStepM_mm/iParams.xU;
end

%% Zeropad sarData to Center
%-------------------------------------------------------------------------%
if (iParams.nFFT > size(sarData,1))
    sarDataPadded = sarData;
    sarDataPadded = padarray(sarDataPadded,[floor((iParams.nFFT-size(sarData,1))/2) 0],0,'pre');
    sarDataPadded = padarray(sarDataPadded,[ceil((iParams.nFFT-size(sarData,1))/2) 0],0,'post');
    sarData = sarDataPadded;
    clear sarDataPadded
else
    iParams.nFFT = size(sarData,1);
end

%% Compute S(kX,k) = FT_x[s(x,k)]: sarDataFFT
%-------------------------------------------------------------------------%
sarDataFFT = fftshift(fft(conj(sarData),[],1),1);

%% Define Paramters for Stolt Interpolation
%-------------------------------------------------------------------------%
kSx = 2*pi/(iParams.xStepM_mm*1e-3);
kX = reshape(linspace(-kSx/2,kSx/2,size(sarData,1)),[],1);

% Consider only visible spectrum of kZ
kZU = reshape(linspace(0,2*max(k)*iParams.zU,size(sarData,2)),1,[]);
kU = 1/2 * sqrt(kX.^2 + kZU.^2);

%% Attempt Stolt Interpolation (kX,k) -> (kX,kZ)
%-------------------------------------------------------------------------%
sarImageFFT = zeros(size(kU));
if ~isempty(gcp('nocreate'))
    parfor ii = 1:size(kU,1)
        sarImageFFT(ii,:) = interp1(k(:),sarDataFFT(ii,:),kU(ii,:),iParams.Stolt,0);
    end
else
    for ii = 1:size(kU,1)
        sarImageFFT(ii,:) = interp1(k(:),sarDataFFT(ii,:),kU(ii,:),iParams.Stolt,0);
    end
end
% Works with: linear,nearest,next,previous,v5cubic

%% Recover the Reflectivity Function
%-------------------------------------------------------------------------%
sarImage = ifft2(sarImageFFT);

%% Display the Reconstructed Image
%-------------------------------------------------------------------------%
xRangeT_m = iParams.xStepM_mm*1e-3 * (-(iParams.nFFT-1)/2 : (iParams.nFFT-1)/2);
zRangeT_m = (1:iParams.nFFT)*iParams.lambda_mm/(4*iParams.nFFT);

figure('OuterPosition',[350 150 670*2 712]);
subplot(121)
mesh(zRangeT_m,xRangeT_m,abs(sarImage),'FaceColor','interp','LineStyle','none')
view(2)
xlim([zRangeT_m(1) zRangeT_m(end)])
ylim([xRangeT_m(1) xRangeT_m(end)])
xlabel("z (m)")
ylabel("x (m)")
title(iParams.scanName + " SAR 2D Image using " + iParams.Stolt + " Method for Stolt Interp")

sarImageLog = mag2db(abs(sarImage));
sarImageLog = sarImageLog - max(sarImageLog(:));
subplot(122)
mesh(zRangeT_m,xRangeT_m,sarImageLog,'FaceColor','interp','LineStyle','none')
xlabel("z (m)")
ylabel("x (m)")
zlabel("dB")
xlim([zRangeT_m(1) zRangeT_m(end)])
ylim([xRangeT_m(1) xRangeT_m(end)])
zlim([-100 0])
title(iParams.scanName + " SAR 2D Log Image using " + iParams.Stolt + " Method for Stolt Interp")