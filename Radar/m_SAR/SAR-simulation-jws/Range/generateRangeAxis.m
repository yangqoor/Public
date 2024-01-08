function rangeAxis = generateRangeAxis(fParams,numRangeFFTBins)

if nargin < 2
    numRangeFFTBins = fParams.adcSample;
end

c = physconst('lightspeed');
rangeIdxToMeters = c * fParams.fS / (2 * fParams.K * fParams.adcSample);
rangeAxis = linspace(0, (fParams.adcSample-1) * rangeIdxToMeters, numRangeFFTBins);