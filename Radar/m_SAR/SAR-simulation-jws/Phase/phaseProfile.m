%% Copyright(C) 2020 The University of Texas at Dallas
%  Developed by: Josiah W. Smith
%  Advisor: Prof. Murat Torlak
%  Department of Electrical and Computer Engineering

%  Redistributions and use of source must retain the above copyright notice
%  Redistributions in binary form must reproduce the above copyright notice

function [rangeDataPeak,xM,yM] = phaseProfile(sarDataIn,iParams,fParams)
%% Declare Optional Parameters
%-------------------------------------------------------------------------%
if iParams.CSAR
    iParams.nUsefulHorMeasurement = iParams.nAngMeasurement;
end

%% Resize the Data
%-------------------------------------------------------------------------%
if iParams.CSAR
    if ndims(sarDataIn) == 4 && min(size(sarDataIn) == [iParams.nAngMeasurement,fParams.adcSample,iParams.nTx*iParams.nRx,iParams.nVerMeasurement])
        % MIMO-CSAR
        % sarDataIn = s(theta,k,nTx*nRx,y)
        sarDataIn = reshape(sarDataIn,[iParams.nAngMeasurement,fParams.adcSample,iParams.nTx*iParams.nRx*iParams.nVerMeasurement]);
        % sarDataIn = s(theta,k,nTx*nRx*y)
        sarDataIn = permute(sarDataIn,[2,3,1]);
        % sarDataIn = s(k,y,theta)
    elseif ndims(sarDataIn) == 3 && min(size(sarDataIn) == [iParams.nAngMeasurement,fParams.adcSample,iParams.nVerMeasurement])
        % SISO-CSAR
        % sarDataIn = s(theta,k,y)
        sarDataIn = permute(sarDataIn,[2,3,1]);
    else
        warning("Input CSAR data is not properly sized")
        return;
    end
else
    if ndims(sarDataIn) == 4 && min(size(sarDataIn) == [iParams.nTx*iParams.nRx,iParams.nVerMeasurement,iParams.nUsefulHorMeasurement,fParams.adcSample])
        % MIMO-SAR
        % sarDataIn = s(nTx*nRx,y,x,k)
        sarDataIn = reshape(sarDataIn,[iParams.nTx*iParams.nRx*iParams.nVerMeasurement,iParams.nUsefulHorMeasurement,fParams.adcSample]);
        % sarDataIn = s(nTx*nRx*y,x,k)
        sarDataIn = permute(sarDataIn,[3,1,2]);
    elseif ndims(sarDataIn) == 3 && min(size(sarDataIn) == [iParams.nVerMeasurement,iParams.nUsefulHorMeasurement,fParams.adcSample])
        % SISO-SAR
        % sarDataIn = s(y,x,k)
        sarDataIn = permute(sarDataIn,[3,1,2]);
    else
        warning("Input SAR data is not properly sized")
        return;
    end
end

if ndims(sarDataIn) ~= 3
    warning("Input SAR data does not have enough dimensions")
end

sarDataFFT = fft(sarDataIn,iParams.nFFT,1);

%% Find Recommended Peak for Phase
%-------------------------------------------------------------------------%
tempRange = mag2db(squeeze(abs(sarDataFFT(:,:))));
maxIdx = zeros(1,size(tempRange,2));

for ii = 1:size(tempRange,2)
    [~,maxIdx(ii)] = max(tempRange(:,ii));
end

maxIdx = mode(maxIdx);

rangeAxis = generateRangeAxis(fParams,iParams.nFFT);

%% Get User Input for Range Peak to Use
%-------------------------------------------------------------------------%
rangeBinIdx = input("What is the range bin index? (Recommended: " + maxIdx + " -> " + rangeAxis(maxIdx) +  "m) ");

if isempty(rangeBinIdx)
    rangeBinIdx = 0;
end

try
    rangeDataPeak = squeeze(sarDataFFT(rangeBinIdx,:,:));
catch
    warning("Invalid input, using recommended")
    rangeDataPeak = squeeze(sarDataFFT(maxIdx,:,:));
end

phaseData2D_A = unwrap(unwrap(angle(rangeDataPeak),[],2),[],1);
phaseData2D_B = unwrap(unwrap(angle(rangeDataPeak),[],1),[],2);

%% Display the Phase Profile
%-------------------------------------------------------------------------%
if iParams.CSAR
    
    thetaM = (0:iParams.nAngMeasurement-1);
    yM = (0:iParams.nVerMeasurement*iParams.nTx*iParams.nRx-1)*iParams.yStepM_mm;
    
    figure
    subplot(221)
    plot(thetaM,squeeze(phaseData2D_B(end/2,:)))
    xlim([thetaM(1) thetaM(end)])
    xlabel("theta (index)")
    ylabel("Phase")
    title("Phase Profile at Vertical Midpoint")
    
    subplot(222)
    plot(yM,squeeze(phaseData2D_A(:,end/2)))
    xlim([yM(1) yM(end)])
    xlabel("y (mm)")
    ylabel("Phase")
    title("Phase Profile at Horizontal Midpoint")
    
    subplot(223)
    mesh(thetaM,yM,phaseData2D_B)
    xlim([thetaM(1) thetaM(end)])
    ylim([yM(1) yM(end)])
    xlabel("theta (index)")
    ylabel("y (mm)")
    title("2D Phase Profile at Range Bin: " + maxIdx + " -> " + rangeAxis(maxIdx) +  "m")
    
    subplot(224)
    mesh(thetaM,yM,phaseData2D_A)
    xlim([thetaM(1) thetaM(end)])
    ylim([yM(1) yM(end)])
    xlabel("theta (index)")
    ylabel("y (mm)")
    title("2D Phase Profile at Range Bin: " + maxIdx + " -> " + rangeAxis(maxIdx) +  "m")
    
else
    
    xM = (0:iParams.nUsefulHorMeasurement-1)*iParams.xStepM_mm;
    yM = (0:iParams.nVerMeasurement*iParams.nTx*iParams.nRx-1)*iParams.yStepM_mm;
    
    figure
    subplot(221)
    plot(xM,squeeze(phaseData2D_B(end/2,:)))
    xlim([xM(1) xM(end)])
    xlabel("x (mm)")
    ylabel("Phase")
    title("Phase Profile at Vertical Midpoint")
    
    subplot(222)
    plot(yM,squeeze(phaseData2D_A(:,end/2)))
    xlim([yM(1) yM(end)])
    xlabel("y (mm)")
    ylabel("Phase")
    title("Phase Profile at Horizontal Midpoint")
    
    subplot(223)
    mesh(xM,yM,phaseData2D_B)
    xlim([xM(1) xM(end)])
    ylim([yM(1) yM(end)])
    xlabel("x (mm)")
    ylabel("y (mm)")
    title("2D Phase Profile at Range Bin: " + maxIdx + " -> " + rangeAxis(maxIdx) +  "m")
    
    subplot(224)
    mesh(xM,yM,phaseData2D_A)
    xlim([xM(1) xM(end)])
    ylim([yM(1) yM(end)])
    xlabel("x (mm)")
    ylabel("y (mm)")
    title("2D Phase Profile at Range Bin: " + maxIdx + " -> " + rangeAxis(maxIdx) +  "m")
    
    %% Find Phase Minimum Point
    %-------------------------------------------------------------------------%
    [~,minIdx] = min(phaseData2D_A(:));
    [idxVer,idxHor] = ind2sub(size(phaseData2D_A),minIdx);
    
    disp("Minimum point at x,y indices: " + idxHor + "," + idxVer + " or (x,y) = (" + xM(idxHor) + "," + yM(idxVer) + ")")
    
end