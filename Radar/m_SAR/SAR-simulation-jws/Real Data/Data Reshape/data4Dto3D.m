function data3D = data4Dto3D(data4D,iParams,fParams)

if iParams.CSAR
    data3D = reshape(data4D,iParams.nAngMeasurement,fParams.adcSample,[]);
else
    
    data3D = reshape(data4D,iParams.nTx*iParams.nRx*iParams.nVerMeasurement,[],fParams.adcSample);
end