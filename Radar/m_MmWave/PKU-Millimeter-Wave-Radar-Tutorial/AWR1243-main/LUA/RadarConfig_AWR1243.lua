------------------------------ CONFIGURATIONS ----------------------------------
-- 下面这三条语句就是用来实现“启动mmwave studio点击set和connect”这两个步骤
ar1.FullReset() 
ar1.SOPControl(2)                 -- 011(SOP mode2) = Device mode
ar1.Connect(4,115200,1000)        -- User UART端口：Com4 | 波特率：115200 

--BSS and MSS firmware download
info = debug.getinfo(1,'S');
-- 获取当前文件的根目录 通常为C:\ti\mmwave_studio_02_01_01_00\mmWaveStudio\Scripts\RadarConfig_AWR1243.lua                                           
file_path = (info.source);
-- 返回时通常有@符号，在下面需要分别替换为空格
file_path = string.gsub(file_path, "@","");
file_path = string.gsub(file_path, "RadarConfig_AWR1243.lua","");
-- 如果你的lua文件名称修改了，你对应也需要在这里修改lua文件的名称，否则会正则匹配失败，无法读取到信息
fw_path   = file_path.."..\\..\\rf_eval_firmware"
-- fw_path为MSS和BSS file文件保存路径，..表示返回到上一级目录，2个..表示范围到前2级目录

--Export bit operation file
bitopfile = file_path.."\\".."bitoperations.lua"
dofile(bitopfile)

--Read part ID
--This register address used to find part number for ES2 and ES3 devices
res, efusedevice = ar1.ReadRegister(0xFFFFE214, 0, 31)
res, efuseES1device = ar1.ReadRegister(0xFFFFE210, 0, 31)
efuseES2ES3Device = bit_and(efusedevice, 0x03FC0000)
efuseES2ES3Device = bit_rshift(efuseES2ES3Device, 18)

--if part number is zero then those are ES1 devices 
if(efuseES2ES3Device == 0) then
	if (bit_and(efuseES1device, 3) == 0) then
		partId = 1243
	elseif (bit_and(efuseES1device, 3) == 1) then
		partId = 1443
	else
		partId = 1642
	end
elseif(efuseES2ES3Device == 0xE0 and (bit_and(efuseES1device, 3) == 2)) then
		partId = 6843
		ar1.frequencyBandSelection("60G")
--if part number is non-zero then those are ES12 and ES3 devices
else
   if(efuseES2ES3Device == 0x20 or efuseES2ES3Device == 0x21 or efuseES2ES3Device == 0x80) then
		partId = 1243
	elseif(efuseES2ES3Device == 0xA0 or efuseES2ES3Device == 0x40)then
		partId = 1443
	elseif(efuseES2ES3Device == 0x60 or efuseES2ES3Device == 0x61 or efuseES2ES3Device == 0x04 or efuseES2ES3Device == 0x62 or efuseES2ES3Device == 0x67) then
		partId = 1642
	elseif(efuseES2ES3Device == 0x66 or efuseES2ES3Device == 0x01 or efuseES2ES3Device == 0xC0 or efuseES2ES3Device == 0xC1) then
		partId = 1642
	elseif(efuseES2ES3Device == 0x70 or efuseES2ES3Device == 0x71 or efuseES2ES3Device == 0xD0 or efuseES2ES3Device == 0x05) then
		partId = 1843
	elseif(efuseES2ES3Device == 0xE0 or efuseES2ES3Device == 0xE1 or efuseES2ES3Device == 0xE2 or efuseES2ES3Device == 0xE3 or efuseES2ES3Device == 0xE4) then
		partId = 6843
		ar1.frequencyBandSelection("60G")
	else
		WriteToLog("Inavlid Device part number in ES2 and ES3 devices\n" ..partId)
    end
end 

--ES version
res, ESVersion = ar1.ReadRegister(0xFFFFE218, 0, 31)
ESVersion = bit_and(ESVersion, 15)

-- Download Firmware 下载所选雷达板对应的固件
if(partId == 1642) then
    BSS_FW    = fw_path.."\\radarss\\xwr16xx_radarss.bin"
    MSS_FW    = fw_path.."\\masterss\\xwr16xx_masterss.bin"
elseif(partId == 1243) then
    BSS_FW    = fw_path.."\\radarss\\xwr12xx_xwr14xx_radarss.bin"
    MSS_FW    = fw_path.."\\masterss\\xwr12xx_xwr14xx_masterss.bin"
elseif(partId == 1443) then
    BSS_FW    = fw_path.."\\radarss\\xwr12xx_xwr14xx_radarss.bin"
    MSS_FW    = fw_path.."\\masterss\\xwr12xx_xwr14xx_masterss.bin"
elseif(partId == 1843) then
    BSS_FW    = fw_path.."\\radarss\\xwr18xx_radarss.bin"
    MSS_FW    = fw_path.."\\masterss\\xwr18xx_masterss.bin"
elseif(partId == 6843) then
    BSS_FW    = fw_path.."\\radarss\\xwr68xx_radarss.bin"
    MSS_FW    = fw_path.."\\masterss\\xwr68xx_masterss.bin"
else
    WriteToLog("Invalid Device partId FW\n" ..partId)
    WriteToLog("Invalid Device ESVersion\n" ..ESVersion)
end

-- Download BSS Firmware
if (ar1.DownloadBSSFw(BSS_FW) == 0) then
    WriteToLog("BSS FW Download Success\n", "green")
else
    WriteToLog("BSS FW Download failure\n", "red")
end

-- Download MSS Firmware
if (ar1.DownloadMSSFw(MSS_FW) == 0) then
    WriteToLog("MSS FW Download Success\n", "green")
else
    WriteToLog("MSS FW Download failure\n", "red")
end

-- SPI Connect
if (ar1.PowerOn(1, 1000, 0, 0) == 0) then
    WriteToLog("Power On Success\n", "green")
else
   WriteToLog("Power On failure\n", "red")
end

-- RF Power UP
if (ar1.RfEnable() == 0) then
    WriteToLog("RF Enable Success\n", "green")
else
    WriteToLog("RF Enable failure\n", "red")
end

-- StaticConfig 雷达通道设置 & ADC设置
-- Tx0=1,Tx1=1,Tx2=1 | Rx0=1,Rx1=1,Rx2=1,Rx3=1 | BitsVal=2 for 16bits | FmtVal=2 for complex2x | IQSwap=0 for I First (I in LSB, Q in MSB, )
if (ar1.ChanNAdcConfig(1, 0, 1, 1, 1, 1, 1, 2, 2, 0) == 0) then
    WriteToLog("ChanNAdcConfig Success\n", "green")
else
    WriteToLog("ChanNAdcConfig failure\n", "red")
end


if (partId == 1642) then
    if (ar1.LPModConfig(0, 1) == 0) then
        WriteToLog("LPModConfig Success\n", "green")
    else
        WriteToLog("LPModConfig failure\n", "red")
    end
else
    if (ar1.LPModConfig(0, 0) == 0) then
        WriteToLog("Regualar mode Cfg Success\n", "green")
    else
        WriteToLog("Regualar mode Cfg failure\n", "red")
    end
end

-- RF Init
if (ar1.RfInit() == 0) then
    WriteToLog("RfInit Success\n", "green")
else
    WriteToLog("RfInit failure\n", "red")
end

RSTD.Sleep(1000)

-- DataConfig
if (ar1.DataPathConfig(1, 1, 0) == 0) then
    WriteToLog("DataPathConfig Success\n", "green")
else
    WriteToLog("DataPathConfig failure\n", "red")
end

if (ar1.LvdsClkConfig(1, 1) == 0) then
    WriteToLog("LvdsClkConfig Success\n", "green")
else
    WriteToLog("LvdsClkConfig failure\n", "red")
end

-- LVDS Lane Configuration
if((partId == 1642) or (partId == 1843) or (partId == 6843)) then
    if (ar1.LVDSLaneConfig(0, 1, 1, 0, 0, 1, 0, 0) == 0) then
        WriteToLog("LVDSLaneConfig Success\n", "green")
    else
        WriteToLog("LVDSLaneConfig failure\n", "red")
    end
elseif ((partId == 1243) or (partId == 1443)) then
    if (ar1.LVDSLaneConfig(0, 1, 1, 1, 1, 1, 0, 0) == 0) then
        WriteToLog("LVDSLaneConfig Success\n", "green")
    else
        WriteToLog("LVDSLaneConfig failure\n", "red")
    end
end

-- TestSource
------------(x,y,z)----Position     | Velocity |  BoundayMin  | BoundaryMax  | Signal Level  |
if (ar1.SetTestSource(  4,   4,   0,  0,  5, 0,   -327, 0, -327,  327, 327, 327, -2.5,  
                        0,   8,   0,  0, -3, 0,   -327, 0, -327,  327, 327, 327, -20,   
					    0, 0,   0.5, 0,   1, 0,   1.5, 0,   3, 0,   0, 0,   5, 0) == 0) then
					  --        Rx Antenna Position       |	Tx Antenna Position (x,z)
    WriteToLog("Test Source Configuration Success\n", "green")
else
    WriteToLog("Test Source Configuration failure\n", "red")
end

-- SensorConfig 
if((partId == 1642) or (partId == 1843)) then
    if(ar1.ProfileConfig(0, 77, 100, 6, 60, 0, 0, 0, 0, 0, 0, 29.982, 0, 256, 5000, 0, 0, 30) == 0) then
        WriteToLog("ProfileConfig Success\n", "green")
    else
        WriteToLog("ProfileConfig failure\n", "red")
    end
elseif((partId == 1243) or (partId == 1443)) then
---- Profile ID=0 | StartFreq = 77 | IdleTime = 10 | ADCStartTime = 6 | RampEndTIme = 63.14 | Slope = 63.343 | TxStartTime = 1 
---- 6个0 for TX0,Tx1,Tx2的PwrBackoff和相移
---- Slope=63.343 | TxStart Time=1 | ADCSample=512 | SampleRate = 9121 | RFGainTarget=default(30dB) | VCOSelect=default(VCO1) | RxGain = 30
    if(ar1.ProfileConfig(0, 77, 10, 6, 63.14,
						 0, 0, 0, 0, 0, 0,
						63.343, 1, 512, 9121, 0, 0, 30) == 0) then
        WriteToLog("ProfileConfig Success\n", "green")
    else
        WriteToLog("ProfileConfig failure\n", "red")
    end
elseif(partId == 6843) then
    if(ar1.ProfileConfig(0, 60.25, 200, 6, 60, 0, 0, 0, 0, 0, 0, 29.982, 0, 128, 10000, 0, 131072, 30) == 0) then
		WriteToLog("ProfileConfig Success\n", "green")
    else
        WriteToLog("ProfileConfig failure\n", "red")
    end
end

-- ChirpConfig 配置天线Tx发射顺序
-- chirpStartIdx | chirpEndIdx  | profileId | 
-- startFreqVar  | freqSlopeVar | idleTimeVar | adcStartTimeVar | 
-- tx0Enable     | tx1Enable    | tx2Enable
if (ar1.ChirpConfig(0, 0, 0, 0, 0, 0, 0, 1, 0, 0) == 0) then     -- 100 for Tx0
    WriteToLog("ChirpConfig Success\n", "green")
else
    WriteToLog("ChirpConfig failure\n", "red")
end

-- if (ar1.ChirpConfig(2, 2, 0, 0, 0, 0, 0, 0, 1, 0) == 0) then     -- 010 for Tx1
    -- WriteToLog("ChirpConfig Success\n", "green")
-- else
    -- WriteToLog("ChirpConfig failure\n", "red")
-- end

if (ar1.ChirpConfig(1, 1, 0, 0, 0, 0, 0, 0, 0, 1) == 0) then     -- 001 for Tx2
    WriteToLog("ChirpConfig Success\n", "green")
else
    WriteToLog("ChirpConfig failure\n", "red")
end

-- Test Source Enable 
-- 若要进行场景实测而忽略仿真源，则注释掉此块代码
if (ar1.EnableTestSource(1) == 0) then
    WriteToLog("Enabling Test Source Success\n", "green")
else
    WriteToLog("Enabling Test Source failure\n", "red")
end
-- if (ar1.DisableTestSource(1) == -1) then
    -- WriteToLog("Disabling Test Source Success\n", "green")
-- else
    -- WriteToLog("Disabling Test Source failure\n", "red")
-- end

-- Frame
-- chirpStartIdx | chirpEndIdx | No of Frame | No of Chirp | Periodicity | triggerDelay | DummyChirp | TriggerSelect
-- 开启3个发射天线Tx 则令 chirpStartIdx = 0 chirpEndIdx = 2
-- TriggerSelect : 1-Softwar(SW) Trigger | 2-Hardware(HW) Trigger
if (ar1.FrameConfig(0, 1, 1, 128, 40, 0, 0, 1) == 0) then
    WriteToLog("FrameConfig Success\n", "green")
else
    WriteToLog("FrameConfig failure\n", "red")
end

-- select Device type
if (ar1.SelectCaptureDevice("DCA1000") == 0) then
    WriteToLog("SelectCaptureDevice Success\n", "green")
else
    WriteToLog("SelectCaptureDevice failure\n", "red")
end

--DATA CAPTURE CARD API
if (ar1.CaptureCardConfig_EthInit("192.168.33.30", "192.168.33.180", "12:34:56:78:90:12", 4096, 4098) == 0) then
    WriteToLog("CaptureCardConfig_EthInit Success\n", "green")
else
    WriteToLog("CaptureCardConfig_EthInit failure\n", "red")
end

--AWR12xx or xWR14xx-1, xWR16xx or xWR18xx or xWR68xx- 2 (second parameter indicates the device type)
if ((partId == 1642) or (partId == 1843) or (partId == 6843)) then
    if (ar1.CaptureCardConfig_Mode(1, 2, 1, 2, 3, 30) == 0) then
        WriteToLog("CaptureCardConfig_Mode Success\n", "green")
    else
        WriteToLog("CaptureCardConfig_Mode failure\n", "red")
    end
elseif ((partId == 1243) or (partId == 1443)) then
    if (ar1.CaptureCardConfig_Mode(1, 1, 1, 2, 3, 30) == 0) then
        WriteToLog("CaptureCardConfig_Mode Success\n", "green")
    else
        WriteToLog("CaptureCardConfig_Mode failure\n", "red")
    end
end

if (ar1.CaptureCardConfig_PacketDelay(25) == 0) then
    WriteToLog("CaptureCardConfig_PacketDelay Success\n", "green")
else
    WriteToLog("CaptureCardConfig_PacketDelay failure\n", "red")
end



