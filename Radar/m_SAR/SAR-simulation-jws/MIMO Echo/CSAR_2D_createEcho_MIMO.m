%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function csarData = CSAR_2D_createEcho_MIMO(iParams,fParams,p)
%% Declare Optional Parameters
%-------------------------------------------------------------------------%
if ~isfield(iParams,"showP")
    iParams.showP = true;
end

%% Declare s(theta,k,y)
%-------------------------------------------------------------------------%
csarData = complex(single(zeros(iParams.nAngMeasurement, fParams.adcSample, iParams.nRx*iParams.nTx*iParams.nVerMeasurement)));

%% Declare Wavenumber Vector
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = single(299792458); % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = single(reshape(k,1,[]));
clear f f0

%% Declare theta Synthetic Aperture Vector
%-------------------------------------------------------------------------%
% thetaM_rad = (0:iParams.tStepM_deg:((iParams.nAngMeasurement-1)*iParams.tStepM_deg))*pi/180;
thetaM_rad = ( (-iParams.nAngMeasurement/2):( (iParams.nAngMeasurement/2) - 1) )*iParams.tStepM_deg*pi/180;
thetaM_rad = single(reshape(thetaM_rad,[],1));

%% Get Array Dimensions
%-------------------------------------------------------------------------%
[yr_orig_m,yt_orig_m,yv_orig_m] = awr1443ArrayDimensions(false);

yr_orig_m = single(reshape(yr_orig_m,1,1,[]));
yt_orig_m = single(reshape(yt_orig_m,1,1,[]));
yv_orig_m = single(reshape(yv_orig_m,1,1,[]));

%% Create yv Synthetic Aperture Axis
%-------------------------------------------------------------------------%
yv = single(zeros(iParams.nRx*iParams.nTx*iParams.nVerMeasurement,1));
for iZ = 1:iParams.nVerMeasurement
    delz2 = single((iZ - (iParams.nVerMeasurement+1)/2) * 2*iParams.lambda_mm * 1e-3);
    yv( ((iZ-1)*iParams.nTx*iParams.nRx + 1):((iZ)*iParams.nTx*iParams.nRx) ) = squeeze(yv_orig_m + delz2 - mean(yv_orig_m));
end

%% Create Echo Signal
%-------------------------------------------------------------------------%
pxyz = single(p.pxyz);
R0 = single(iParams.R0_mm*1e-3); % m
cthetaM = single(cos(thetaM_rad));
sthetaM = single(sin(thetaM_rad));

sizeSarData = size(csarData);

if ~isempty(gcp('nocreate'))
    parfor ixP = 1:p.xLim
        for iyP = 1:p.yLim
            for izP = 1:p.zLim
                if pxyz(ixP,iyP,izP) > 1e-8
                    stot = complex(single(zeros(sizeSarData)));
                    for delz = single((-(iParams.nVerMeasurement-1)/2:1:(iParams.nVerMeasurement-1)/2) * 2*iParams.lambda_mm * 1e-3)
                        
                        yr = yr_orig_m + delz - mean(yv_orig_m);
                        yt = yt_orig_m + delz - mean(yv_orig_m);
                        
                        Rr = single(sqrt( (R0*cthetaM - p.xT(ixP)).^2 + (R0*sthetaM - p.zT(izP)).^2 + (yr - p.yT(iyP)).^2));
                        Rt = single(sqrt( (R0*cthetaM - p.xT(ixP)).^2 + (R0*sthetaM - p.zT(izP)).^2 + (yt - p.yT(iyP)).^2));
                        
                        s = complex(single(zeros(length(thetaM_rad),length(k),iParams.nRx*iParams.nTx)));
                        s(:,:,1:iParams.nRx*iParams.nTx/2) = pxyz(ixP,iyP,izP) .* (Rt(:,:,1).*Rr).^(-1) .* exp(1j*k.*(Rt(:,:,1) + Rr) - 1j*pi*fParams.K/(c^2).*(Rt(:,:,1)+Rr).^2);
                        s(:,:,iParams.nRx*iParams.nTx/2+1:end) = pxyz(ixP,iyP,izP) .* (Rt(:,:,2).*Rr).^(-1) .* exp(1j*k.*(Rt(:,:,2) + Rr) - 1j*pi*fParams.K/(c^2).*(Rt(:,:,2)+Rr).^2);
                        
                        idxStart = (delz/(2*iParams.lambda_mm*1e-3) + (iParams.nVerMeasurement-1)/2)*iParams.nTx*iParams.nRx + 1;
                        idxEnd = (delz/(2*iParams.lambda_mm*1e-3) + (iParams.nVerMeasurement-1)/2 + 1)*iParams.nTx*iParams.nRx;
                        
                        stot(:,:,idxStart:idxEnd) = s;
                    end
                    
                    csarData = csarData + stot;
                end
            end
        end
    end
else
    for ixP = 1:p.xLim
        for iyP = 1:p.yLim
            for izP = 1:p.zLim
                if pxyz(ixP,iyP,izP) > 1e-8
                    stot = complex(single(zeros(sizeSarData)));
                    for delz = single((-(iParams.nVerMeasurement-1)/2:1:(iParams.nVerMeasurement-1)/2) * 2*iParams.lambda_mm * 1e-3)
                        
                        yr = yr_orig_m + delz - mean(yv_orig_m);
                        yt = yt_orig_m + delz - mean(yv_orig_m);
                        
                        Rr = single(sqrt( (R0*cthetaM - p.xT(ixP)).^2 + (R0*sthetaM - p.zT(izP)).^2 + (yr - p.yT(iyP)).^2));
                        Rt = single(sqrt( (R0*cthetaM - p.xT(ixP)).^2 + (R0*sthetaM - p.zT(izP)).^2 + (yt - p.yT(iyP)).^2));
                        
                        s = complex(single(zeros(length(thetaM_rad),length(k),iParams.nRx*iParams.nTx)));
                        s(:,:,1:iParams.nRx*iParams.nTx/2) = pxyz(ixP,iyP,izP) .* (Rt(:,:,1).*Rr).^(-1) .* exp(1j*k.*(Rt(:,:,1) + Rr) - 1j*pi*fParams.K/(c^2).*(Rt(:,:,1)+Rr).^2);
                        s(:,:,iParams.nRx*iParams.nTx/2+1:end) = pxyz(ixP,iyP,izP) .* (Rt(:,:,2).*Rr).^(-1) .* exp(1j*k.*(Rt(:,:,2) + Rr) - 1j*pi*fParams.K/(c^2).*(Rt(:,:,2)+Rr).^2);
                        
                        idxStart = (delz/(2*iParams.lambda_mm*1e-3) + (iParams.nVerMeasurement-1)/2)*iParams.nTx*iParams.nRx + 1;
                        idxEnd = (delz/(2*iParams.lambda_mm*1e-3) + (iParams.nVerMeasurement-1)/2 + 1)*iParams.nTx*iParams.nRx;
                        
                        stot(:,:,idxStart:idxEnd) = s;
                    end
                    
                    csarData = csarData + stot;
                end
            end
        end
    end
end

%% Look at the reflectivity function
%-------------------------------------------------------------------------%
if iParams.showP
    disp("Displaying the Non-Zero Z-Domain Slices")
    for izP = 1:p.zLim
        if squeeze(mean(p.pxyz(:,:,izP),[1,2])) > 0
            figure
            mesh(flip(squeeze(p.xT)),flip(squeeze(p.yT)),flipud(squeeze(p.pxyz(:,:,izP)).'),'FaceColor','interp','LineStyle','none')
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
