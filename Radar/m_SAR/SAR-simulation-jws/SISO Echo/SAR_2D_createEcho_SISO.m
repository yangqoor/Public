%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function syxk = SAR_2D_createEcho_SISO(iParams,fParams,p)

%% Declare Optional Parameters
%-------------------------------------------------------------------------%
if ~isfield(iParams,"showP")
    iParams.showP = true;
end

%% Maintain everything in the size of:
% nVerMeasurement x nHorMeasurement x adcSample
%-------------------------------------------------------------------------%
syxk = zeros(iParams.nVerMeasurement,iParams.nUsefulHorMeasurement,fParams.adcSample);

%% Declare Wavenumber Vector
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = reshape(k,1,1,[]);
clear f f0

%% Declare Spatial X Vector
%-------------------------------------------------------------------------%
xM_m = (0:iParams.nUsefulHorMeasurement-1)*iParams.xStepM_mm*1e-3;
if mod(iParams.nUsefulHorMeasurement,2) == 0
    xM_m = xM_m - xM_m(end/2);
else
    xM_m = xM_m - xM_m( (end+1)/2 );
end
xM_m = reshape(xM_m,1,[]);

%% Declare Spatial Y Vector
%-------------------------------------------------------------------------%
yM_m = (0:iParams.nVerMeasurement-1)*iParams.yStepM_mm*1e-3;
if mod(iParams.nVerMeasurement,2) == 0
    yM_m = yM_m - yM_m(end/2);
else
    yM_m = yM_m - yM_m( (end+1)/2 );
end
yM_m = reshape(yM_m,[],1);

%% Create Echo Signal
%-------------------------------------------------------------------------%
[xM_m,yM_m,k] = meshgrid(xM_m,yM_m,k);

if ~isempty(gcp('nocreate')) % if parallel pool is open
    pxyz = p.pxyz;
    parfor ixP = 1:p.xLim
        for iyP = 1:p.yLim
            for izP = 1:p.zLim
                if pxyz(ixP,iyP,izP) > 1e-8
                    R = sqrt((xM_m - p.xT(ixP)).^2 + (yM_m - p.yT(iyP)).^2 + (p.zT(izP)).^2);
                    syxk = syxk + pxyz(ixP,iyP,izP) .* (R.^(-2)) .* exp(1j*2*k.*R - 1j*pi*fParams.K*(2*R/c).^2));
                end
            end
        end
    end
else
    pxyz = p.pxyz;
    for ixP = 1:p.xLim
        for iyP = 1:p.yLim
            for izP = 1:p.zLim
                if pxyz(ixP,iyP,izP) > 1e-8
                    R = sqrt((xM_m - p.xT(ixP)).^2 + (yM_m - p.yT(iyP)).^2 + (p.zT(izP)).^2);
                    syxk = syxk + pxyz(ixP,iyP,izP) .* (R.^(-2)) .* exp(1j*2*k.*R - 1j*pi*fParams.K*(2*R/c).^2));
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

