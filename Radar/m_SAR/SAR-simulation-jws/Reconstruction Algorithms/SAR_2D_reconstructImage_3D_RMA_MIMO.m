%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [sarImage3D,xRangeT_m,yRangeT_m,zRangeT_m] = SAR_2D_reconstructImage_3D_RMA_MIMO(sarData,iParams,fParams,p)
% Reconstructs a 3D image from SAR echo data using the range migration
% algorithm (RMA). Expects a 2D rectilinear scan across the x-axis with a
% MIMO transceiver and the y-axis with a MIMO transceiver

%% Input Arguments
%-------------------------------------------------------------------------%
% sarData: iParams.nVerMeasurement*iParams.nTx*iParams.nRx x iParams.nUsefulHorMeasurement x fParams.adcSample single, double, or gpuArray
% sarData: s(y,x,k)
%
% iParams: struct with fields
%   z0_mm               :   Distance of target
%   xStepM_mm           :   Step size of x-axis in mm
%   yStepM_mm           :   Step size of y-axis in mm
%   scanName            :   Name of the scan
%   Stolt               :   Interpolation method for RMA
%   xyzSizeT_m          :   Expected size of the target in the xz domain in m
%   resize              :   Boolean if output image should be resized
%   displayResult       :   Boolean if the output image should be shown
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
%   xLim                :   Size of x-axis of target domain
%   yLim                :   Size of y-axis of target domain
%   zLim                :   Size of z-axis of target domain

%% Declare Optional Parameters
%-------------------------------------------------------------------------%
if ~isfield(iParams,"Stolt")
    iParams.Stolt = "v5cubic";
end
if ~isfield(iParams,"mex")
    iParams.mex = true;
end
if ~isfield(iParams,'xyzSizeT_m') && nargin < 4
    iParams.xyzSizeT_m = 0.4;
end
if ~isfield(iParams,'resize')
    iParams.resize = true;
end
if ~isfield(iParams,'displayResult')
    iParams.displayResult = false;
end

tic

%% Zeropad sarData
%-------------------------------------------------------------------------%
sarDataPadded = sarData;
if (iParams.nFFT > size(sarData,1))
    sarDataPadded = padarray(sarDataPadded,[floor((iParams.nFFT-size(sarData,1))/2) 0],0,'pre');
    sarDataPadded = padarray(sarDataPadded,[ceil((iParams.nFFT-size(sarData,1))/2) 0],0,'post');
else
    iParams.nFFT = size(sarData,1);
end
if (iParams.nFFT > size(sarData,2))
    sarDataPadded = padarray(sarDataPadded,[0 floor((iParams.nFFT-size(sarData,2))/2)],0,'pre');
    sarDataPadded = padarray(sarDataPadded,[0 ceil((iParams.nFFT-size(sarData,2))/2)],0,'post');
else
    iParams.nFFT = size(sarData,2);
end
clear sarData

%% Obtain S(kY,kX,k): sarDataFFT
%-------------------------------------------------------------------------%
sarDataFFT = fftshift(fftshift(fft(fft(conj(sarDataPadded),iParams.nFFT,1),iParams.nFFT,2),1),2);
clear sarDataPadded

%% Define Interpolation Parameters
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency
c = 299792458; % m/s
k = reshape(2*pi*f/c,1,1,[]); % Wavenumber Vector

kSx = 2*pi/(iParams.xStepM_mm*1e-3);
kX = reshape(linspace(-kSx/2,kSx/2,iParams.nFFT),1,[]);

kSy = 2*pi/(iParams.yStepM_mm*1e-3);
kY = reshape(linspace(-kSy/2,kSy/2,iParams.nFFT),[],1);

% Consider only visible spectrum of kZ
kZU = reshape(linspace(0,2*max(k),iParams.nFFT),1,1,[]);
KU = 1/2 * sqrt(kY.^2 + kX.^2 + kZU.^2);
clear c f f0 kSx kX kSy kY kZU

%% Attempt Stolt Interpolation S(kY,kX,k) -> S(kY,kX,kZ)
%-------------------------------------------------------------------------%
disp("Attempting 3D Stolt interpolation using " + iParams.Stolt + " method")
if iParams.mex
    sarImageFFT = stoltInterp3D_mex(sarDataFFT,k,KU);
else
    sarImageFFT = stoltInterp3D(sarDataFFT,k,KU);
end
% Works with: linear,nearest,next,previous,v5cubic
sarImageFFT(isnan(sarImageFFT)) = 0;
clear sarData KU k fParams sizeKU2

%% Recover the Reflectivity Function
%-------------------------------------------------------------------------%
sarImage3D = single(abs(ifftn(sarImageFFT,[iParams.nFFT,iParams.nFFT,iParams.nFFT])));

%% Correct Dimensions of Reconstruced Data (y,x,z) -> (x,y,z)
%-------------------------------------------------------------------------%

sarImage3D = permute(sarImage3D,[2,1,3]);

disp("Completed 3D RMA in " + toc + " seconds")

%% Crop the Image for Related Region
%-------------------------------------------------------------------------%
xRangeT_m = iParams.xStepM_mm*1e-3 * (-(iParams.nFFT-1)/2 : (iParams.nFFT-1)/2);
yRangeT_m = iParams.yStepM_mm*1e-3 * (-(iParams.nFFT-1)/2 : (iParams.nFFT-1)/2);
zRangeT_m = (1:iParams.nFFT)*iParams.lambda_mm/(2*iParams.nFFT);

if (nargin == 4)
    indX = xRangeT_m >= (p.xT(1)) & xRangeT_m <= (p.xT(end));
    indY = yRangeT_m >= (p.yT(1)) & yRangeT_m <= (p.yT(end));
    indZ = zRangeT_m >= (p.zT(1)) & zRangeT_m <= (p.zT(end));
    xRangeT_m = xRangeT_m(indX);
    yRangeT_m = yRangeT_m(indY);
    zRangeT_m = zRangeT_m(indZ);
    sarImage3D = sarImage3D(indX,indY,indZ);
    clear indX indY indZ
elseif (iParams.xyzSizeT_m ~= -1)
    indX = xRangeT_m>(-iParams.xyzSizeT_m/2 + mean(diff(xRangeT_m))) & xRangeT_m<(iParams.xyzSizeT_m/2);
    indY = yRangeT_m>(-iParams.xyzSizeT_m/2 + mean(diff(yRangeT_m))) & yRangeT_m<(iParams.xyzSizeT_m/2);
    indZ = zRangeT_m>(-iParams.xyzSizeT_m/2 + mean(diff(zRangeT_m))) & zRangeT_m<(iParams.xyzSizeT_m/2);
    xRangeT_m = xRangeT_m(indX);
    yRangeT_m = yRangeT_m(indY);
    zRangeT_m = zRangeT_m(indZ);
    sarImage3D = sarImage3D(indX,indY,indZ);
    clear indX indY indZ
end
if iParams.resize
%     csarImageFull = sarImage3D;
    sarImage3D = imresize3(abs(sarImage3D),[p.xLim,p.yLim,p.zLim]);
    xRangeT_m = p.xT;
    yRangeT_m = p.yT;
    zRangeT_m = p.zT;
end

sarImage3D = permute(rot90(permute(sarImage3D,[3,1,2]),2),[2,3,1]);

%% Display the Result
%-------------------------------------------------------------------------%
if iParams.displayResult
    volumeViewer(abs(sarImage3D));
end