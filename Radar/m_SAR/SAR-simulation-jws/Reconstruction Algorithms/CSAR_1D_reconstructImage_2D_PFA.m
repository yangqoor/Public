%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [csarImage,xRangeT_m,zRangeT_m] = CSAR_1D_reconstructImage_2D_PFA(csarData,iParams,fParams)
% Reconstructs a 2D image from CSAR echo data using the polar reformatting
% algorithm (PFA), performed by built-in MATLAB interpolation. Optional
% upsampling improves image quality

%% Input Arguments
%-------------------------------------------------------------------------%
% csarData: iParams.nAngMeasurement x fParams.adcSample single, double, or gpuArray
%
% iParams: struct with fields
%   nAngMeasurements    :   Number of angular measurements
%   tStepM_deg          :   Step size of angular measurements in degrees
%   R0_mm               :   Scanning radius
%   xzSizeT_m           :   Expected size of the target in the xz domain in m
%   scanName            :   Name of the scan
%   PFA                 :   Interpolation method for PFA (default: 'linear')
%   af                  :   Azimuth Filter Type (default: 1)
%   nFFT                :   Number of FFT bins to use (before upsampling)
%   xU                  :   Upsampling factor in x-axis
%   zU                  :   Upsampling factor in z-axis
%
% fParams: struct with fields
%   K                   :   Chrip Slope (Hz/s)
%   fS                  :   Sampling frequency (1/s)
%   adcSample           :   Number of samples
%   ADCStartTime        :   Time it takes to start sampling (s)
%   f0                  :   Chirp start frequency (Hz)

%% Declare Optional Parameters
%-------------------------------------------------------------------------%
if ~isfield(iParams,'scanName')
    iParams.scanName = 'CSAR-PFA';
end
if ~isfield(iParams,'PFA')
    iParams.PFA = 'linear';
end
if ~isfield(iParams,'xU')
    iParams.xU = 4;
end
if ~isfield(iParams,'zU')
    iParams.zU = 4;
end
if ~isfield(iParams,'xzSizeT_m')
    iParams.xzSizeT_m = 0.4;
end
if ~isfield(iParams,'displayResult')
    iParams.displayResult = true;
end
if ~isfield(iParams,'af')
    iParams.af = 1;
end

tic

%% Declare Wavenumber Vector
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = reshape(k,1,[]);
clear f f0

%% Declare theta_rad Synthetic Aperture Vector
%-------------------------------------------------------------------------%
% theta_rad = (0:iParams.tStepM_deg:((iParams.nAngMeasurement-1)*iParams.tStepM_deg))*pi/180;
% theta_rad = reshape(theta_rad,[],1);

theta_rad = ( (-iParams.nAngMeasurement/2):( (iParams.nAngMeasurement/2) - 1) )*iParams.tStepM_deg*pi/180;
theta_rad = reshape(theta_rad,[],1);

%% Declare kX and kZ
%-------------------------------------------------------------------------%
kX = 2*k.*cos(theta_rad);
kZ = 2*k.*sin(theta_rad);

kXmax = max(max(kX));
kZmax = max(max(kZ));
kXmin = min(min(kX));
kZmin = min(min(kZ));

%% Declare kXU and kZU
%-------------------------------------------------------------------------%
% According to Ozdemir
kXU = reshape(linspace(iParams.xU*kXmin,iParams.xU*kXmax,iParams.xU*iParams.nFFT),[],1);
kZU = reshape(linspace(iParams.zU*kZmin,iParams.zU*kZmax,iParams.zU*iParams.nFFT),1,[]);

kXUsteps = mean(diff(kXU));
kZUsteps = mean(diff(kZU));

%% Declare Uniform theta_radU and kU for Interpolation
%-------------------------------------------------------------------------%
theta_radU = atan2(kZU,kXU);
kU = (1/2)*sqrt(kXU.^2 + kZU.^2);

%% Upsample csarData using interp
%-------------------------------------------------------------------------%
kUpsample = reshape(linspace(min(k),max(k),length(kZU)),1,[]);
theta_radUpsample = reshape(linspace(min(theta_rad),max(theta_rad),length(kXU)),[],1);

csarDataUpsampled = interpn(theta_rad,k,csarData,theta_radUpsample,kUpsample,iParams.PFA,0);

%% Compute Azimuth Filter: h(theta,k)
%-------------------------------------------------------------------------%
azimuthFilter = exp(1j*2*kUpsample*(iParams.R0_mm*1e-3).*cos(theta_radUpsample));
azimuthFilterFFT = fft(azimuthFilter,[],1);

%% Compute Azimuth Filtered Data: p(theta,k) = IFT[ s(Theta,k) * H*(Theta,k) ]
%-------------------------------------------------------------------------%
csarDataUpsampledFFT = fft(csarDataUpsampled,[],1);

if iParams.af == 1
    % Multiply by Conjugate of Azimuth Filter FFT in Fourier Theta Domain
    azimuthFiltered = conj(ifft(csarDataUpsampledFFT .* conj(azimuthFilterFFT),[],1));
elseif iParams.af == 2
    % Multipy by Only Phase of Azimuth Filter FFT
    azimuthFiltered = conj(ifft(csarDataUpsampledFFT .* exp(-1j*angle(azimuthFilterFFT)),[],1));
elseif iParams.af == 3
    % Hankel Function Asymptotic Approximation
    dtheta = mean(diff(theta_rad));
    Theta = reshape((0:(length(theta_radUpsample)-1))/(2*dtheta*length(theta_radUpsample)),[],1);
    azimuthFilterFFT = exp(-1j*sqrt(4* (kUpsample).^2 * (iParams.R0_mm*1e-3)^2 - Theta.^2));
    azimuthFiltered = ifft(csarDataUpsampledFFT .* azimuthFilterFFT,[],1);
elseif iParams.af == 4
    % Division in Fourier Theta Domain to Perform Deconvolution
    azimuthFiltered = conj(ifft(csarDataUpsampledFFT ./ azimuthFilterFFT,[],1));
end

%% Interpolate Azimuth Filtered Data to CSAR Image FFT: p(kX,kZ)
%-------------------------------------------------------------------------%
csarImageFFT = interpn(theta_radUpsample,kUpsample,azimuthFiltered,theta_radU,kU,iParams.PFA,0);

%% Recover CSAR Image: p(x,z)
%-------------------------------------------------------------------------%
csarImage = ifftshift(ifft2(csarImageFFT));

%% Crop the Image for Related Region
%-------------------------------------------------------------------------%
xRangeT_m = (-size(csarImage,1)/2:(size(csarImage,1)/2-1))*(2*pi/(kXUsteps*length(kXU)));
zRangeT_m = (-size(csarImage,2)/2:(size(csarImage,2)/2-1))*(2*pi/(kZUsteps*length(kZU)));

if (iParams.xzSizeT_m ~= -1)
    indX = xRangeT_m>(-iParams.xzSizeT_m/2) & xRangeT_m<(iParams.xzSizeT_m/2);
    indZ = zRangeT_m>(-iParams.xzSizeT_m/2) & zRangeT_m<(iParams.xzSizeT_m/2);
    xRangeT_m = xRangeT_m(indX);
    zRangeT_m = zRangeT_m(indZ);
    csarImage = csarImage(indX,indZ);
end

disp("Completed 2D PFA in " + toc + " seconds")

%% Display the Result
%-------------------------------------------------------------------------%
if iParams.displayResult
    figure('OuterPosition',[350 150 670*2 712]);
    subplot(121)
    mesh(zRangeT_m,xRangeT_m,abs(csarImage),'FaceColor','interp','LineStyle','none')
    view(2)
    xlim([zRangeT_m(1) zRangeT_m(end)])
    ylim([xRangeT_m(1) xRangeT_m(end)])
    xlabel("z (m)")
    ylabel("x (m)")
    title(iParams.scanName + " CSAR 2D Image using MATLAB " + iParams.PFA + " Interpolation")
    
    csarImageLog = mag2db(abs(csarImage));
    csarImageLog = csarImageLog - max(csarImageLog(:));
    subplot(122)
    mesh(zRangeT_m,xRangeT_m,csarImageLog,'FaceColor','interp','LineStyle','none')
    xlabel("z (m)")
    ylabel("x (m)")
    zlabel("dB")
    csarImageLog(csarImageLog < -100) = -100;
    xlim([zRangeT_m(1) zRangeT_m(end)])
    ylim([xRangeT_m(1) xRangeT_m(end)])
    zlim([-100 0])
    title(iParams.scanName + " CSAR 2D Log Image using MATLAB " + iParams.PFA + " Interpolation")
end