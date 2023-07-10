
%% 读取惯导
fid_read_scale = fopen('.\QS_Data147_ZD.bin','r');

for k = 1 : 80
    Data_Sum_All = zeros(1,NrNew);
    for m =1:1
    %% 第一组 包头
    Test00 = fread(fid_read_scale,8,'uint64');
     %% 第二组 ZD信息
     % 帧头 帧长 帧序号 工作模式
     Test1 = fread(fid_read_scale,5,'uint8');
     %B6B7
     Test2 = fread(fid_read_scale,1,'uint16');
     %重频
     Prf = fread(fid_read_scale,1,'uint16');
     %脉压
     Test3 = fread(fid_read_scale,2,'uint8');
     %固定门限
     Test4 = fread(fid_read_scale,2,'uint32');
     %图像量化门限
     Test5 = fread(fid_read_scale,1,'uint16');
     %图像量化方式
     Test6 = fread(fid_read_scale,3,'uint8');
     %距离起点
     Test7 = fread(fid_read_scale,1,'uint16');
     Rmin =Test7*2.0-1000.0;
     %备用
     Test8 = fread(fid_read_scale,2,'uint8');
      %波束方位角
     Test9 = fread(fid_read_scale,1,'int16');
     Tmp = Test9*90.0/32768.0*pi/180.0;
     a_Azi(k) = Tmp;
     a_Azi_0(k) = a_Azi(k)*180/pi;
     %波束俯仰角
     Test9 = fread(fid_read_scale,1,'int16');
     Tmp = Test9*90.0/32768.0*pi/180.0;
     a_Ele(k) = Tmp;
     a_Ele_0(k) = Tmp*180/pi;
      %安装方位角
     Test9 = fread(fid_read_scale,1,'int16');
     Platform_Azi = Test9*90.0/32768.0*pi/180.0;
      %安装俯仰角
     Test9 = fread(fid_read_scale,1,'int16');
      Platform_Ele = Test9*90.0/32768.0*pi/180.0;
      %方位差斜率
     Test10 = fread(fid_read_scale,2,'int16');
      %目标背景与海况等级
     Test11 = fread(fid_read_scale,6,'uint8');
      %备用
     Test12 = fread(fid_read_scale,1,'uint16');
      %软件更新
     Test13 = fread(fid_read_scale,4,'uint8');
     Test14 = fread(fid_read_scale,1,'uint32');
     Test15 = fread(fid_read_scale,1,'uint64');
     
     
    %%第三组 惯导信息
       %帧号
     Test20 = fread(fid_read_scale,1,'uint16');
        %新增6B 
     Test21 = fread(fid_read_scale,2+3,'uint16');
     
     A_north(k) =fread(fid_read_scale,1,'uint16')*0.01;
     A_sky(k) =fread(fid_read_scale,1,'uint32')*1e-5;
     A_east(k) =fread(fid_read_scale,1,'uint16')*0.01;
     
     V_north(k) =fread(fid_read_scale,1,'uint32')*0.01;
     V_sky(k) =fread(fid_read_scale,1,'uint32')*0.01;
     V_east(k) =fread(fid_read_scale,1,'uint32')*0.01;
     
     % 俯仰、偏航、横滚角速度
      Test22 = fread(fid_read_scale,3,'uint16');
      
     beta(k) =fread(fid_read_scale,1,'uint16')*1e-4;
     alpha(k) =fread(fid_read_scale,1,'uint16')*1e-4;
     roll(k) =fread(fid_read_scale,1,'uint16')*1e-4;
     
      Test23 = fread(fid_read_scale,3,'uint16');
      
      %高度
      Y_sky(k) = fread(fid_read_scale,1,'uint32');
      %经度
      Longitude(k) = fread(fid_read_scale,1,'uint32')*1e-8;
      %经度
      Longitude(k) = fread(fid_read_scale,1,'uint32')*1e-8;
      % 新增6B
      fseek(fid_read_scale,16+8*7-6,'cof');
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      V = sqrt(V_north(k)^2+ V_sky(k)^2+V_east(k)^2);
end
end
fclose all;