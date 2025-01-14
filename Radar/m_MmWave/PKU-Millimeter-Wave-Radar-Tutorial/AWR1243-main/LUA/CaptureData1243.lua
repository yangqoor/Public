adc_data_path="D:\\Radar\\AWR1243\\ReadData\\RawData_0\\adc_data.bin"
ar1.CaptureCardConfig_StartRecord(adc_data_path, 1)
RSTD.Sleep(1000)
ar1.StartFrame()
