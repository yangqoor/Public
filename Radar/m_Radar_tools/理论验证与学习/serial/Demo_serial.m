clear;clc;

%--------------------------------------------------------------------------
%   配置串口
%--------------------------------------------------------------------------
s=serial('com4');s.BytesAvailableFcnMode='byte';
s.InputBufferSize=4096;s.OutputBufferSize=1024;
s.BytesAvailableFcnCount=100;s.ReadAsyncMode='continuous';
s.Terminator='CR';

%--------------------------------------------------------------------------
%   打开串口
%--------------------------------------------------------------------------
fopen(s);
data=fread(s,100,'uint8');
%--------------------------------------------------------------------------
%   关闭串口
%--------------------------------------------------------------------------
fclose(s);