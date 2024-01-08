function data4D = data3Dto4D(data3D,iParams,fParams)

if iParams.CSAR
    data4D = reshape(data3D,iParams.nAngMeasurement,fParams.adcSample,iParams.nTx*iParams.nRx,[]);
else
    data4D = reshape(data3D,iParams.nTx*iParams.nRx,iParams.nVerMeasurement,[],fParams.adcSample);
end