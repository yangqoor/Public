%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function sarData = SAR_1D_createEcho_MIMO(iParams,fParams,p)
%% Declare p(y,k): sarData
%-------------------------------------------------------------------------%
sarData = zeros(iParams.nRx*iParams.nTx*iParams.nVerMeasurement,fParams.adcSample);

%% Declare Wavenumber Vector
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = reshape(k,1,[]);
clear f f0

%% Get Array Dimensions
%-------------------------------------------------------------------------%
[yr_orig_m,yt_orig_m,yv_orig_m] = awr1443ArrayDimensions(false);

%% Define p(y,z): pyz
%-------------------------------------------------------------------------%
if mod(p.xLim,2) == 0
    pyz = squeeze(p.pxyz(end/2,:,:));
else
    pyz = squeeze(p.pxyz((end+1)/2,:,:));
end

sizeSarData = size(sarData);

if ~isempty(gcp('nocreate')) % if parallel pool is open
    parfor iyP = 1:p.yLim
        for izP = 1:p.zLim
            if pyz(iyP,izP) > 1e-8
                stot = zeros(sizeSarData);
                for dely = (-(iParams.nVerMeasurement-1)/2:1:(iParams.nVerMeasurement-1)/2) * 2*iParams.lambda_mm * 1e-3
                    
                    yr = yr_orig_m.' + dely - yv_orig_m(end/2);
                    yt = yt_orig_m.' + dely - yv_orig_m(end/2);
                    
                    Rr = sqrt( (p.yT(iyP) - yr).^2 + (p.zT(izP))^2);
                    Rt = sqrt( (p.yT(iyP) - yt).^2 + (p.zT(izP))^2);
                    
                    s = zeros(iParams.nRx*iParams.nTx,length(k));
                    s(1:iParams.nRx*iParams.nTx/2,:) = pyz(iyP,izP) .* (Rt(1,:).*Rr).^(-1) .* exp(1j*k.*(Rt(1,:) + Rr) - 1j*pi*fParams.K/(c^2).*(Rt(1,:)+Rr).^2);
                    s(iParams.nRx*iParams.nTx/2+1:end,:) = pyz(iyP,izP) .* (Rt(2,:).*Rr).^(-1) .* exp(1j*k.*(Rt(2,:) + Rr) - 1j*pi*fParams.K/(c^2).*(Rt(2,:)+Rr).^2);
                    
                    idxStart = round((dely/(2*iParams.lambda_mm*1e-3) + (iParams.nVerMeasurement-1)/2)*iParams.nTx*iParams.nRx + 1);
                    idxEnd = round((dely/(2*iParams.lambda_mm*1e-3) + (iParams.nVerMeasurement-1)/2 + 1)*iParams.nTx*iParams.nRx);
                    
                    stot(idxStart:idxEnd,:) = s;
                end
                
                sarData = sarData + stot;
            end
        end
    end
else                     % but if the parallel pool is not open
    for iyP = 1:p.yLim
        for izP = 1:p.zLim
            if pyz(iyP,izP) > 1e-8
                stot = zeros(sizeSarData);
                for dely = (-(iParams.nVerMeasurement-1)/2:1:(iParams.nVerMeasurement-1)/2) * 2*iParams.lambda_mm * 1e-3
                    
                    yr = yr_orig_m.' + dely - yv_orig_m(end/2);
                    yt = yt_orig_m.' + dely - yv_orig_m(end/2);
                    
                    Rr = sqrt( (p.yT(iyP) - yr).^2 + (p.zT(izP))^2);
                    Rt = sqrt( (p.yT(iyP) - yt).^2 + (p.zT(izP))^2);
                    
                    s = zeros(iParams.nRx*iParams.nTx,length(k));
                    s(1:iParams.nRx*iParams.nTx/2,:) = pyz(iyP,izP) .* (Rt(1,:).*Rr).^(-1) .* exp(1j*k.*(Rt(1,:) + Rr) - 1j*pi*fParams.K/(c^2).*(Rt(1,:)+Rr).^2);
                    s(iParams.nRx*iParams.nTx/2+1:end,:) = pyz(iyP,izP) .* (Rt(2,:).*Rr).^(-1) .* exp(1j*k.*(Rt(2,:) + Rr) - 1j*pi*fParams.K/(c^2).*(Rt(2,:)+Rr).^2);
                    
                    idxStart = round((dely/(2*iParams.lambda_mm*1e-3) + (iParams.nVerMeasurement-1)/2)*iParams.nTx*iParams.nRx + 1);
                    idxEnd = round((dely/(2*iParams.lambda_mm*1e-3) + (iParams.nVerMeasurement-1)/2 + 1)*iParams.nTx*iParams.nRx);
                    
                    stot(idxStart:idxEnd,:) = s;
                end
                
                sarData = sarData + stot;
            end
        end
    end
end

%% Display the Reflectivity Function
%-------------------------------------------------------------------------%
figure;
mesh(p.zT,p.yT,pyz,'FaceColor','interp','LineStyle','none');
title("Reflectivity Function of Target Scene")
xlabel("z (m)")
ylabel("y (m)")