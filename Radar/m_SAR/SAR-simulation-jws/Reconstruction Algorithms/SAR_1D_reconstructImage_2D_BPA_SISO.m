%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [sarImage,xRangeT_m,zRangeT_m] = SAR_1D_reconstructImage_2D_BPA_SISO(sarDataX,iParams,fParams,p)
% Reconstructs a 2D image from SAR echo data using the back projection
% algorithm (BPA). Expects a 1D scan across the x-axis using a SISO
% transceiver.

%% Input Arguments
%-------------------------------------------------------------------------%
% sarData: iParams.nUsefulHorMeasurement x fParams.adcSample single, double, or gpuArray
%
% iParams: struct with fields
%   xStepM_mm           :   Step size of x-axis in mm
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
%   pxyz                :   Reflectivity function p(x,y,z)
%   xT                  :   x-axis of target domain
%   zT                  :   z-axis of target domain

%% Declare Optional Parameters
%-------------------------------------------------------------------------%
if ~isfield(iParams,'isAmplitudeFactor')
    iParams.isAmplitudeFactor = false;
end

%% Declare Wavenumber Vector
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = reshape(k,1,[]);
clear c f f0

%% Declare x Synthetic Aperture Vector
%-------------------------------------------------------------------------%
xM = (0:iParams.nUsefulHorMeasurement-1)*iParams.xStepM_mm*1e-3;
if mod(iParams.nUsefulHorMeasurement,2) == 0
    xM = xM - xM(end/2);
else
    xM = xM - xM( (end+1)/2 );
end
xM = reshape(xM,[],1);

%% Recover Image by BPA
%-------------------------------------------------------------------------%
xRangeT_m = p.xT;
zRangeT_m = p.zT;
sarImage = zeros(length(xRangeT_m),length(zRangeT_m));

lengthz = length(zRangeT_m);
if ~isempty(gcp('nocreate'))
    parfor ixP = 1:length(xRangeT_m)
        for izP = 1:lengthz
            R = sqrt( (xM - xRangeT_m(ixP)).^2 + (zRangeT_m(izP)).^2 );
            if iParams.isAmplitudeFactor
                sarImage(ixP,izP) = sum(sum(sarDataX.*R.^2.*exp(-1j*R*2*k)));
            else
                sarImage(ixP,izP) = sum(sum(sarDataX.*exp(-1j*R*2*k)));
            end
        end
    end
else
    for ixP = 1:length(xRangeT_m)
        for izP = 1:lengthz
            R = sqrt( (xM - xRangeT_m(ixP)).^2 + (zRangeT_m(izP)).^2 );
            if iParams.isAmplitudeFactor
                sarImage(ixP,izP) = sum(sum(sarDataX.*R.^2.*exp(-1j*R*2*k)));
            else
                sarImage(ixP,izP) = sum(sum(sarDataX.*exp(-1j*R*2*k)));
            end
        end
    end
end

%% Display the Reconstructed Image
%-------------------------------------------------------------------------%
figure('OuterPosition',[350 150 670*2 712]);
subplot(121)
mesh(zRangeT_m,xRangeT_m,abs(sarImage),'FaceColor','interp','LineStyle','none')
view(2)
xlim([zRangeT_m(1) zRangeT_m(end)])
ylim([xRangeT_m(1) xRangeT_m(end)])
xlabel("z (m)")
ylabel("x (m)")
title(iParams.scanName + " SAR 2D Image using BPA")

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
title(iParams.scanName + " SAR 2D Log Image using BPA")