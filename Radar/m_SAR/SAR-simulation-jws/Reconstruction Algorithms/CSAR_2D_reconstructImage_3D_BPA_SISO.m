%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [csarImage,xRangeT_m,yRangeT_m,zRangeT_m] = CSAR_2D_reconstructImage_3D_BPA_SISO(csarData,iParams,fParams,p)
% Reconstructs 2D image from CSAR echo data using the back projection
% algorithm (BPA). BPA requires pixel by pixel integral that is
% computationally inefficient. WARNING: WILL TAKE HOURS/DAYS TO COMPLETE!!

%% Input Arguments
% csarData: iParams.nAngMeasurement x fParams.adcSample x iParams.nVerMeasurement
%
% iParams: struct with fields
%   nAngMeasurements    :   Number of angular measurements
%   tStepM_deg          :   Step size of angular measurements in degrees
%   nVerMeasurements    :   Number of vertical measurements
%   yStepM_mm           :   Step size of vertical axis in mm
%   R0_mm               :   Scanning radius
%   scanName            :   Name of the scan
%   nFFT                :   Number of FFT bins to use (before upsampling)
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
theta_rad = ( (-iParams.nAngMeasurement/2):( (iParams.nAngMeasurement/2) - 1) )*iParams.tStepM_deg*pi/180;
theta_rad = reshape(theta_rad,[],1);

%% Declare yM Synthetic Aperture Vector
%-------------------------------------------------------------------------%
yM_m = (0:iParams.nVerMeasurement-1)*iParams.yStepM_mm*1e-3;
if mod(iParams.nVerMeasurement,2) == 0
    yM_m = yM_m - yM_m(end/2);
else
    yM_m = yM_m - yM_m( (end+1)/2 );
end
yM_m = reshape(yM_m,1,1,[]);

%% Do Image Reconstruction
%-------------------------------------------------------------------------%
xRangeT_m = p.xT;
yRangeT_m = yM_m;
zRangeT_m = p.zT;
csarImage = complex(single(zeros(length(xRangeT_m),length(yRangeT_m),length(zRangeT_m))));
lengthy = length(yRangeT_m);
lengthz = length(zRangeT_m);
R0_m = iParams.R0_mm*1e-3;

if ~isempty(gcp('nocreate'))
    parfor ixP = 1:length(xRangeT_m)
        for iyP = 1:lengthy
            for izP = 1:lengthz
                R = sqrt( (R0_m*cos(theta_rad) - xRangeT_m(ixP)).^2 + (R0_m*sin(theta_rad) - zRangeT_m(izP)).^2 + (yM_m - yRangeT_m(iyP)).^2);
                if iParams.isAmplitudeFactor
                    csarImage(ixP,iyP,izP) = sum(csarData.*R.^(2).*exp(-1j.*R.*2.*k),'all');
                else
                    csarImage(ixP,iyP,izP) = sum(csarData.*exp(-1j.*R.*2.*k),'all');
                end
            end
        end
    end
else
    for ixP = 1:length(xRangeT_m)
        for iyP = 1:lengthy
            for izP = 1:lengthz
                R = sqrt( (R0_m*cos(theta_rad) - xRangeT_m(ixP)).^2 + (R0_m*sin(theta_rad) - zRangeT_m(izP)).^2 + (yM_m - yRangeT_m(iyP)).^2);
                if iParams.isAmplitudeFactor
                    csarImage(ixP,iyP,izP) = sum(csarData.*R.^(2).*exp(-1j*R.*2.*k),'all');
                else
                    csarImage(ixP,iyP,izP) = sum(csarData.*exp(-1j*R.*2.*k),'all');
                end
            end
        end
    end
end

%% Display the Result
%-------------------------------------------------------------------------%
volumeViewer(csarImage);