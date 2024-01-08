%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function sarData = SAR_1D_createEcho_SISO(iParams,fParams,p)
%% Declare s(x,k): sarData
%-------------------------------------------------------------------------%
sarData = zeros(iParams.nUsefulHorMeasurement,fParams.adcSample);

%% Declare Wavenumber Vector
%-------------------------------------------------------------------------%
f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency

c = 299792458; % physconst('lightspeed'); in m/s
k = 2*pi*f/c;
k = reshape(k,1,[]);
clear f f0

%% Declare xM Spatial Vector
%-------------------------------------------------------------------------%
xM_m = (0:iParams.nUsefulHorMeasurement-1)*iParams.xStepM_mm*1e-3;
if mod(iParams.nUsefulHorMeasurement,2) == 0
    xM_m = xM_m - xM_m(end/2);
else
    xM_m = xM_m - xM_m( (end+1)/2 );
end
xM_m = reshape(xM_m,[],1);

%% Declare p(x,z): pxz
%-------------------------------------------------------------------------%
if mod(p.yLim,2) == 0
    pxz = squeeze(p.pxyz(:,end/2,:));
else
    pxz = squeeze(p.pxyz(:,(end+1)/2,:));
end

%% Create Echo Signal
%-------------------------------------------------------------------------%
if ~isempty(gcp('nocreate')) % if parallel pool is open
    parfor ixP = 1:p.xLim
        for izP = 1:p.zLim
            if pxz(ixP,izP) > 1e-8
                R = sqrt((p.zT(izP)).^2 + (xM_m - p.xT(ixP)).^2);
                sarData = sarData + pxz(ixP,izP) .* (R.^(-2)) .* exp(1j*2*k.*R - 1j*pi*fParams.K*(2*R/c).^2);
            end
        end
    end
else                     % but if the parallel pool is not open
    for ixP = 1:p.xLim
        for izP = 1:p.zLim
            if pxz(ixP,izP) > 1e-8
                R = sqrt((p.zT(izP)).^2 + (xM_m - p.xT(ixP)).^2);
                sarData = sarData + pxz(ixP,izP) .* (R.^(-2)) .* exp(1j*2*k.*R - 1j*pi*fParams.K*(2*R/c).^2);
            end
        end
    end
end

%% Display the Reflectivity Function
%-------------------------------------------------------------------------%
figure;
mesh(p.zT,p.xT*1e3,pxz);
title("Reflectivity Function of Target Scene")
xlabel("z (m)")
ylabel("x (mm)")
