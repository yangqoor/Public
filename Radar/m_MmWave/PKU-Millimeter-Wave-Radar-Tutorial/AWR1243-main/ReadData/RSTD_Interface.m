function RSTD_Interface(RSTD_DLL_Path)
addpath(genpath('.\'))

% Initialize mmWaveStudio .NET connection
ErrStatus = Init_RSTD_Connection(RSTD_DLL_Path);
if (ErrStatus ~= 30000)
    disp('Error inside Init_RSTD_Connection');
    return;
end

end

% Example on how to get mmWaveStudio to run an external Lua Script. 
%{
strFilename = 
'C:\\ti\\mmwave_studio_01_00_00_01\\mmWaveStudio\\Scripts\\Example_script_AllDevices.lua'; 
Lua_String = sprintf('dofile("%s")',strFilename); 
ErrStatus =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String); 
%}