%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [sarDataOut,phaseCorrectionFactor] = phaseCorrection(sarDataIn,iParams,fParams)
% Can handle both 2D and 3D sarDataIn arrays

%% Declare Optional Parameters
%-------------------------------------------------------------------------%
if ~isfield(iParams,"CSAR")
    iParams.CSAR = false;
end

if ~iParams.CSAR
    %% Check size of sarDataIn
    %---------------------------------------------------------------------%
    if size(sarDataIn,1) ~= iParams.nRx*iParams.nTx*iParams.nVerMeasurement
        warning("sarData is not properly shaped")
        return;
    end
    
    %% Declare Wavenumber Vector
    %---------------------------------------------------------------------%
    f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
    f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency
    
    c = 299792458; % physconst('lightspeed'); in m/s
    k = 2*pi*f/c;
    if ndims(sarDataIn) == 3 && size(sarDataIn,3) == fParams.adcSample
        k = reshape(k,1,1,[]);
    elseif ismatrix(sarDataIn) && size(sarDataIn,2) == fParams.adcSample
        k = reshape(k,1,[]);
    end
    clear c f f0
    
    %% Get Array Dimensions
    %---------------------------------------------------------------------%
    [zr,zt] = awr1443ArrayDimensions(false);
    
    dz_r = [zt(1) - zr , zt(2) - zr].';
    
    %% Phase Correction
    %---------------------------------------------------------------------%
    phaseCorrectionFactor = exp(-1j* k .* dz_r.^2 / (4*iParams.z0_mm*1e-3));
    
    phaseCorrectionFactor = repmat(phaseCorrectionFactor,[iParams.nVerMeasurement,1,1]);
    
    sarDataOut = sarDataIn .* phaseCorrectionFactor;
elseif iParams.CSAR
    %% Maintain everything in the size of:
    % nAngMeasurement x adcSample x nRx*nTx*nVerMeasurement
    %---------------------------------------------------------------------%
    if size(sarDataIn) ~= [iParams.nAngMeasurement,fParams.adcSample,iParams.nRx*iParams.nTx*iParams.nVerMeasurement]
        warning("sarData is not the right size")
        return;
    end
    
    %% Declare Wavenumber Vector
    %---------------------------------------------------------------------%
    f0 = fParams.f0 + fParams.ADCStartTime*fParams.K; % This is for ADC sampling offset
    f = f0 + (0:fParams.adcSample-1)*fParams.K/fParams.fS; % wideband frequency
    
    c = 299792458; % physconst('lightspeed'); in m/s
    k = 2*pi*f/c;
    k = reshape(k,1,[]);
    clear c f f0
    
    %% Get Array Dimensions
    %---------------------------------------------------------------------%
    [zr,zt] = awr1443ArrayDimensions(false);
    
    dz_r = [zt(1) - zr , zt(2) - zr];
    dz_r = reshape(dz_r,1,1,[]);
    
    %% Phase Correction
    %---------------------------------------------------------------------%
    phaseCorrectionFactor = exp(-1j* k .* dz_r.^2 / (4*iParams.R0_mm*1e-3));
    
    phaseCorrectionFactor = single(repmat(phaseCorrectionFactor,[1,1,iParams.nVerMeasurement]));
    
    sarDataOut = sarDataIn .* phaseCorrectionFactor;
end