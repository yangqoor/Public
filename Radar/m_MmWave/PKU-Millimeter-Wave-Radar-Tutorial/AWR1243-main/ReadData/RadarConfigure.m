function RadarConfigure

    % Initialize mmWaveStudio .NET connection
    RSTD_DLL_Path = 'D:\ti\mmwave_studio_02_01_01_00\mmWaveStudio\Clients\RtttNetClientController\RtttNetClientAPI.dll';
    RSTD_Interface(RSTD_DLL_Path);
    
    % Get mmWaveStudio to run an external Lua Script. 
    strFilename ='D:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\RadarConfig_AWR1243.lua'; 
    Lua_String = sprintf('dofile("%s")',strFilename);
    ErrStatus = RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    
end
