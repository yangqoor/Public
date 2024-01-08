%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function sarImage = SAR_2D_reconstructImage_3D_BPA_MIMO(sarData,iParams,fParams,p)
% Reconstructs a 3D image from SAR echo data using the back projection
% algorithm (BPA). Expects a 2D rectilinear scan across the x-axis with a
% SISO transceiver and the y-axis with a MIMO transceiver

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

%% Declare Optional Paramters
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

%% Declare x Synthetic Aperture Vector
%-------------------------------------------------------------------------%
xM = (0:iParams.nUsefulHorMeasurement-1)*iParams.xStepM_mm*1e-3;
if mod(iParams.nUsefulHorMeasurement,2) == 0
    xM = xM - xM(end/2);
else
    xM = xM - xM( (end+1)/2 );
end
xM = reshape(xM,1,[]);

%% Declare Spatial y Vector
%-------------------------------------------------------------------------%
yM = (0:iParams.nVerMeasurement*iParams.nTx*iParams.nRx-1)*iParams.yStepM_mm*1e-3;
if mod(iParams.nVerMeasurement*iParams.nTx*iParams.nRx,2) == 0
    yM = yM - yM(end/2);
else
    yM = yM - yM( (end+1)/2 );
end
yM = reshape(yM,[],1);

%% Compute BPA
%-------------------------------------------------------------------------%
x = p.xT;
y = p.yT;
z = p.zT;
sarImage = zeros(length(x),length(y),length(z));

sarData = permute(sarData,[1,2,4,3]);

lenghty = length(y);
lengthz = length(z);
for ixP = 1:length(x)
    for iyP = 1:lenghty
        for izP = 1:lengthz
            R = sqrt( (xM - x(ixP)).^2 + (yM - y(iyP)).^2 + (z(izP)).^2 );
            if iParams.isAmplitudeFactor
                sarImage(ixP,iyP,izP) = sum(sarData.*R.^2.*exp(-1j*2*R.*k),'all');
            else
                sarImage(ixP,iyP,izP) = sum(sarData.*exp(-1j*R*2*k),'all');
            end
        end
    end
end

%% Display Result
%-------------------------------------------------------------------------%
volumeViewer(abs(sarImage));