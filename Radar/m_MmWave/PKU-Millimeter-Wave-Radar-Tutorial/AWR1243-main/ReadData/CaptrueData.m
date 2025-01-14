% 可参考的完整执行逻辑
% 可以做一个APP或GUI分块管理，笔者实现过，还是可以的。
clc;clear;close all;
% AWR1243雷达配置（只需初始化一次即可）
run('RadarConfigure.m');  

%% 实际测试需要修改数据变量文件名称
root_path = 'D:\Radar\AWR1243\ReadData\'; % 根路径名称
data_name = 'RawData_0';
data_path = strcat(root_path,data_name);

adc_file_name = strcat(data_path,'\adc_data_Raw_0.bin'); % 检测该文件夹下是否存在bin文件

% 向DCA1000发送采集数据的指令并保存adc_data_Raw0.bin
SendCaptureCMD(data_name); 

