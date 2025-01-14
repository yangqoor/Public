function SendCaptureCMD(data_name)
    %% ���ļ�����MATLAB����ָ���mmwave ����DCA�ɼ����ش�����
    root_path = 'D:\Radar\AWR1243\ReadData\';
    data_path = strcat(root_path,data_name); 
    mkdir(data_path); % �����ļ���
    
    %% �޸Ĳɼ����ݵĽű��ļ�
    str1 = strcat('adc_data_path="D:\\Radar\\AWR1243\\ReadData\\',data_name,'\\adc_data.bin"'); % ���bin�ļ�Ŀ¼
    str = [str1,"ar1.CaptureCardConfig_StartRecord(adc_data_path, 1)","RSTD.Sleep(1000)","ar1.StartFrame()"];
    fid = fopen('D:\ti\mmwave_studio_02_01_01_00\mmWaveStudio\Scripts\CaptureData1243.lua','w');
    for i = 1:length(str)
        fprintf(fid,'%s\n',str(i));
    end
    fclose(fid); % �ر��ļ�
    
    %% �����״����ݲɼ�
    % Initialize mmWaveStudio .NET connection
    RSTD_DLL_Path = 'D:\ti\mmwave_studio_02_01_01_00\mmWaveStudio\Clients\RtttNetClientController\RtttNetClientAPI.dll';
    RSTD_Interface(RSTD_DLL_Path);
    
    % Get mmWaveStudio to run an external Lua Script. 
    strFilename = 'D:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\CaptureData1243.lua';
    Lua_String = sprintf('dofile("%s")',strFilename);
    ErrStatus = RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
end
