%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function sarData = SAR_2D_createEcho_MIMO(iParams,fParams,p)
%% Declare Optional Parameters
%-------------------------------------------------------------------------%
if ~isfield(iParams,"showP")
    iParams.showP = true;
end
if ~isfield(iParams,"mex")
    iParams.mex = false;
end

%% Declare s(y,x,k): sarData
%-------------------------------------------------------------------------%
sarData = zeros(iParams.nRx*iParams.nTx*iParams.nVerMeasurement,iParams.nUsefulHorMeasurement,fParams.adcSample);

%% Declare Wavenumber Vector
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = reshape(k,1,1,[]);
clear f f0

%% Declare Spatial of Synthetic Aperture X-Vector
%-------------------------------------------------------------------------%
xM_m = (0:iParams.nUsefulHorMeasurement-1)*iParams.xStepM_mm*1e-3;
if mod(iParams.nUsefulHorMeasurement,2) == 0
    xM_m = xM_m - xM_m(end/2);
else
    xM_m = xM_m - xM_m( (end+1)/2 );
end
xM_m = reshape(xM_m,1,[]);

%% Get Array Dimensions
%-------------------------------------------------------------------------%
[yr_orig_m,yt_orig_m,yv_orig_m] = awr1443ArrayDimensions(false);

%% Create Echo Signal
%-------------------------------------------------------------------------%
tic
if iParams.mex
    % Potentially faster
    nVerMeasurement = iParams.nVerMeasurement;
    lambda = iParams.lambda_mm;
    nTx = iParams.nTx;
    nRx = iParams.nRx;
    KSlope = fParams.K;
    sarData = createSARechoMIMO3DMiniPar_mex(sarData,nVerMeasurement,lambda,nTx,nRx,KSlope,p,xM_m,yr_orig_m,yt_orig_m,yv_orig_m,k);
    clear nVerMeasurement lambda nTx nRx KSlope
else
    pxyz = p.pxyz;
    sizeSarData = size(sarData);
    if ~isempty(gcp('nocreate'))
        parfor ixP = 1:p.xLim   % or use regular for loops
            for iyP = 1:p.yLim
                for izP = 1:p.zLim
                    if pxyz(ixP,iyP,izP) > 1e-8
                        stot = zeros(sizeSarData);
                        for dely = (-(iParams.nVerMeasurement-1)/2:1:(iParams.nVerMeasurement-1)/2) * 2*iParams.lambda_mm * 1e-3
                            yr = yr_orig_m.' + dely - yv_orig_m(end/2);
                            yt = yt_orig_m.' + dely - yv_orig_m(end/2);
                            
                            Rr = sqrt( (p.xT(ixP) - xM_m).^2 + (p.yT(iyP) - yr).^2 + (p.zT(izP))^2);
                            Rt = sqrt( (p.xT(ixP) - xM_m).^2 + (p.yT(iyP) - yt).^2 + (p.zT(izP))^2);
                            
                            s = zeros(iParams.nRx*iParams.nTx,length(xM_m),length(k));
                            s(1:iParams.nRx*iParams.nTx/2,:,:) = pxyz(ixP,iyP,izP) .* (Rt(1,:).*Rr).^(-1) .* exp(1j*k.*(Rt(1,:) + Rr) - 1j*pi*fParams.K/(c^2).*(Rt(1,:)+Rr).^2);
                            s(iParams.nRx*iParams.nTx/2+1:end,:,:) = pxyz(ixP,iyP,izP) .* (Rt(2,:).*Rr).^(-1) .* exp(1j*k.*(Rt(2,:) + Rr) - 1j*pi*fParams.K/(c^2).*(Rt(2,:)+Rr).^2);
                            
                            idxStart = round((dely/(2*iParams.lambda_mm*1e-3) + (iParams.nVerMeasurement-1)/2)*iParams.nTx*iParams.nRx + 1);
                            idxEnd = round((dely/(2*iParams.lambda_mm*1e-3) + (iParams.nVerMeasurement-1)/2 + 1)*iParams.nTx*iParams.nRx);
                            
                            stot(idxStart:idxEnd,:,:) = s;
                        end
                        
                        sarData = sarData + stot;
                    end
                end
            end
        end
    else
        for ixP = 1:p.xLim   % or use regular for loops
            for iyP = 1:p.yLim
                for izP = 1:p.zLim
                    if pxyz(ixP,iyP,izP) > 1e-8
                        stot = zeros(sizeSarData);
                        for dely = (-(iParams.nVerMeasurement-1)/2:1:(iParams.nVerMeasurement-1)/2) * 2*iParams.lambda_mm * 1e-3
                            yr = yr_orig_m.' + dely - yv_orig_m(end/2);
                            yt = yt_orig_m.' + dely - yv_orig_m(end/2);
                            
                            Rr = sqrt( (p.xT(ixP) - xM_m).^2 + (p.yT(iyP) - yr).^2 + (p.zT(izP))^2);
                            Rt = sqrt( (p.xT(ixP) - xM_m).^2 + (p.yT(iyP) - yt).^2 + (p.zT(izP))^2);
                            
                            s = zeros(iParams.nRx*iParams.nTx,length(xM_m),length(k));
                            s(1:iParams.nRx*iParams.nTx/2,:,:) = pxyz(ixP,iyP,izP) .* (Rt(1,:).*Rr).^(-1) .* exp(1j*k.*(Rt(1,:) + Rr) - 1j*pi*fParams.K/(c^2).*(Rt(1,:)+Rr).^2);
                            s(iParams.nRx*iParams.nTx/2+1:end,:,:) = pxyz(ixP,iyP,izP) .* (Rt(2,:).*Rr).^(-1) .* exp(1j*k.*(Rt(2,:) + Rr) - 1j*pi*fParams.K/(c^2).*(Rt(2,:)+Rr).^2);
                            
                            idxStart = round((dely/(2*iParams.lambda_mm*1e-3) + (iParams.nVerMeasurement-1)/2)*iParams.nTx*iParams.nRx + 1);
                            idxEnd = round((dely/(2*iParams.lambda_mm*1e-3) + (iParams.nVerMeasurement-1)/2 + 1)*iParams.nTx*iParams.nRx);
                            
                            stot(idxStart:idxEnd,:,:) = s;
                        end
                        
                        sarData = sarData + stot;
                    end
                end
            end
        end
    end
end
disp("Echo took " + toc + " seconds to complete")

%% Display the Reflectivity Function
%-------------------------------------------------------------------------%
if iParams.showP
    disp("Displaying the Non-Zero Z-Domain Slices")
    for izP = 1:p.zLim
        if squeeze(mean(p.pxyz(:,:,izP),[1,2])) > 0
            figure
            mesh(flip(squeeze(p.xT)),flip(squeeze(p.yT)),flipud(squeeze(p.pxyz(:,:,izP)).'))
            title("Reflectivity Function")
            view(2)
            xlabel("x")
            ylabel("y")
            title("2D Image at z = " + p.zT(izP))
        end
    end
    
    clear izP
    
    volumeViewer(abs(p.pxyz))
end
