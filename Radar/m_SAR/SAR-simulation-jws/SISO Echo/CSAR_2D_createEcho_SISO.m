%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function csarData = CSAR_2D_createEcho_SISO(iParams,fParams,p)

%% Declare Optional Parameters
%-------------------------------------------------------------------------%
if ~isfield(iParams,"showP")
    iParams.showP = true;
end

%% Maintain everything in the size of:
% nAngMeasurement x adcSample x nVerMeasurement
%-------------------------------------------------------------------------%
csarData = complex(single(zeros(iParams.nAngMeasurement, fParams.adcSample, iParams.nVerMeasurement)));

%% Declare Wavenumber Vector
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = single(reshape(k,1,[]));
clear f f0

%% Declare theta Synthetic Aperture Vector
%-------------------------------------------------------------------------%
thetaM_rad = (0:iParams.tStepM_deg:((iParams.nAngMeasurement-1)*iParams.tStepM_deg))*pi/180;
thetaM_rad = reshape(thetaM_rad,[],1);

%% Declare yM Synthetic Aperture Vector
%-------------------------------------------------------------------------%
yM_m = (0:iParams.nVerMeasurement-1)*iParams.yStepM_mm*1e-3;
if mod(iParams.nVerMeasurement,2) == 0
    yM_m = yM_m - yM_m(end/2);
else
    yM_m = yM_m - yM_m( (end+1)/2 );
end
yM_m = single(reshape(yM_m,1,1,[]));

%% Create Echo Signal
%-------------------------------------------------------------------------%
R0 = single(iParams.R0_mm*1e-3); % m
pxyz = single(p.pxyz);
if ~isempty(gcp('nocreate'))
    parfor ixP = 1:p.xLim
        for iyP = 1:p.yLim
            for izP = 1:p.zLim
                if pxyz(ixP,iyP,izP) > 1e-8
                    R = sqrt( (R0*cos(thetaM_rad) - p.xT(ixP)).^2 + (R0*sin(thetaM_rad) - p.zT(izP)).^2 + (yM_m - p.yT(iyP)).^2 );
                    csarData = csarData + pxyz(ixP,iyP,izP) .* (R.^(-2)) .* exp(1j*2*k.*R - 1j*pi*fParams.K*(2*R/c).^2);
                end
            end
        end
    end
else
    for ixP = 1:p.xLim
        for iyP = 1:p.yLim
            for izP = 1:p.zLim
                if pxyz(ixP,iyP,izP) > 1e-8
                    R = sqrt( (R0*cos(thetaM_rad) - p.xT(ixP)).^2 + (R0*sin(thetaM_rad) - p.zT(izP)).^2 + (yM_m - p.yT(iyP)).^2 );
                    csarData = csarData + pxyz(ixP,iyP,izP) .* (R.^(-2)) .* exp(1j*2*k.*R - 1j*pi*fParams.K*(2*R/c).^2);
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
