%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [csarImage,xRangeT_m,zRangeT_m] = CSAR_1D_reconstructImage_2D_BPA(csarData,iParams,fParams,p)
% Reconstructs 2D image from CSAR echo data using the back projection
% algorithm (BPA). BPA requires pixel by pixel integral that is
% computationally inefficient. Expects a 1D scan across theta

%% Input Arguments
%-------------------------------------------------------------------------%
% csarData: iParams.nAngMeasurement x fParams.adcSample single, double, or gpuArray
%
% iParams: struct with fields
%   nAngMeasurements    :   Number of angular measurements
%   tStepM_deg          :   Step size of angular measurements in degrees
%   R0_mm               :   Scanning radius
%   scanName            :   Name of the scan
%
% fParams: struct with fields
%   K                   :   Chrip Slope (Hz/s)
%   fS                  :   Sampling frequency (1/s)
%   adcSample           :   Number of samples
%   ADCStartTime        :   Time it takes to start sampling (s)
%   f0                  :   Chirp start frequency (Hz)

%% Declare Optional Parameters
%-------------------------------------------------------------------------%
if ~isfield(iParams,'AmplitudeFactor')
    iParams.AmplitudeFactor = true;
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

%% Declare theta Synthetic Aperture Vector
%-------------------------------------------------------------------------%
% theta_rad = (0:iParams.tStepM_deg:((iParams.nAngMeasurement-1)*iParams.tStepM_deg))*pi/180;
% theta_rad = reshape(theta_rad,[],1);

theta_rad = ( (-iParams.nAngMeasurement/2):( (iParams.nAngMeasurement/2) - 1) )*iParams.tStepM_deg*pi/180;
theta_rad = reshape(theta_rad,[],1);

%% Do Image Reconstruction
%-------------------------------------------------------------------------%
xRangeT_m = p.xT;
zRangeT_m = p.zT;
csarImage = zeros(length(xRangeT_m),length(zRangeT_m));
lengthz = length(zRangeT_m);
R0_m = iParams.R0_mm*1e-3;

if ~isempty(gcp('nocreate'))
    parfor ixP = 1:length(xRangeT_m)
        for izP = 1:lengthz
            R = sqrt( (R0_m*cos(theta_rad) - xRangeT_m(ixP)).^2 + (R0_m*sin(theta_rad) - zRangeT_m(izP)).^2 );
            if iParams.isAmplitudeFactor
                % Slower
                %             pxz(ixP,izP) = trapz(k(:),trapz(thetaM(:),csarData.*R.^2.*exp(-1j*R*2*k),1),2);
                % Faster!
                csarImage(ixP,izP) = sum(csarData.*R.^(2).*exp(-1j*R*2*k),'all');
            else
                csarImage(ixP,izP) = sum(csarData.*exp(-1j*R*2*k),'all');
            end
        end
    end
else
    for ixP = 1:length(xRangeT_m)
        for izP = 1:lengthz
            R = sqrt( (R0_m*cos(theta_rad) - xRangeT_m(ixP)).^2 + (R0_m*sin(theta_rad) - zRangeT_m(izP)).^2 );
            if iParams.isAmplitudeFactor
                % Slower
                %             pxz(ixP,izP) = trapz(k(:),trapz(thetaM(:),csarData.*R.^2.*exp(-1j*R*2*k),1),2);
                % Faster!
                csarImage(ixP,izP) = sum(csarData.*R.^(2).*exp(-1j*R*2*k),'all');
            else
                csarImage(ixP,izP) = sum(csarData.*exp(-1j*R*2*k),'all');
            end
        end
    end
end

disp("Completed 2D Circular BPA in " + toc + " seconds")

%% Display the Result
%-------------------------------------------------------------------------%
figure('OuterPosition',[350 150 670*2 712]);
subplot(121)
mesh(zRangeT_m,xRangeT_m,abs(csarImage),'FaceColor','interp','LineStyle','none')
view(2)
xlim([zRangeT_m(1) zRangeT_m(end)])
ylim([xRangeT_m(1) xRangeT_m(end)])
xlabel("z (m)")
ylabel("x (m)")
title(iParams.scanName + " ISAR 2D Image using BPA")

logpxz = mag2db(abs(csarImage));
logpxz = logpxz - max(logpxz(:));
subplot(122)
mesh(zRangeT_m,xRangeT_m,logpxz,'FaceColor','interp','LineStyle','none')
xlabel("z (m)")
ylabel("x (mm)")
zlabel("dB")
xlim([zRangeT_m(1) zRangeT_m(end)])
ylim([xRangeT_m(1) xRangeT_m(end)])
zlim([-100 0])
title(iParams.scanName + " ISAR 2D Log Image using BPA")