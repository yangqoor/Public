%%%%&&&&&&&& Xilinx FFT IP Core测试 &&&&&&&&
%%# 说明：先运行程序【1】产生Test Data of FPGA ，执行【2】之前不能重复运行【1】，【2】是比较FPGA和MATLAB的 FFT
% MATLAB联合FPGA仿真输入/输出功能测试
%%%【1】****** input data(matrix) test for FFT IP Core******
clc;
clear all;
close all;

%%%******Initialize Parameters******
Amplitude = 1;                                         % 信号幅度
sigma_2 = 0.1;                                         % 噪声方差
Len_Pulse = 1000;                                      % 距离单元数(一个脉冲数据长度)
N = 32;                                                % 脉冲个数
fr = 10e3;                                             % 脉冲重复频率
tr = 1 / fr;
fs = 1e7;                                              % 采样频率(fs=fr*Len_Pulse)
ts = 1 / fs;
fd = 1e3;                                              % 多普勒频率

%%%******产生雷达回波信号******
n = 1:Len_Pulse * N;
echo_pulse = [zeros(1, 100), 1, 1, zeros(1, Len_Pulse - 102)];
echo_pulse_N = repmat(echo_pulse, 1, N);               % 脉冲
Signal_N = Amplitude * exp(1i * 2 * pi * fd * ts * n); % 连续信号
noise_I = sqrt(sigma_2) * randn(1, Len_Pulse * N);
noise_Q = sqrt(sigma_2) * randn(1, Len_Pulse * N);
noise_N = noise_I + 1i * noise_Q;                      % noise
% Signal=ones(1,Len_Pulse*N);
Signal = Signal_N .* echo_pulse_N + noise_N;           % N个脉冲雷达回波信号

% %%%******写test数据到.txt文件******
% Signal_test=fix(Signal*2^10);    % input data test
% Signal_test_real=fix(real(Signal_test));              % real
% Signal_test_imag=fix(imag(Signal_test));              % imag
% Signal_test_real(find(Signal_test_real<0))=Signal_test_real(find(Signal_test_real<0))+2^20;  % 负数转换成补码
% Signal_test_imag(find(Signal_test_imag<0))=Signal_test_imag(find(Signal_test_imag<0))+2^20;
% fid_real=fopen('data_test_input_real_matrix.txt','wt');
% fid_imag=fopen('data_test_input_imag_matrix.txt','wt');
% fprintf(fid_real,'%x\n',Signal_test_real);
% fprintf(fid_imag,'%x\n',Signal_test_imag);
% fclose(fid_real);
% fclose(fid_imag);
% Signal=Signal_test;

% figure();
% subplot(2,1,1),  plot(n,Signal_N);
% title('雷达回波信号')
% subplot(2,1,2),  plot(n,Signal);
% title('N个脉冲雷达回波信号(含噪声)');

Signal_matrix = reshape(Signal, Len_Pulse, N); % 数据矩阵(Len_Pulse个距离单元,N个脉冲)
% figure();
% plot(1:Len_Pulse,Signal_matrix(:,1));

NF = 32; % NF点FFT

for i = 1:Len_Pulse % 多普勒滤波器组
    s_temp = Signal_matrix(i, :);
    s_mtd(i, :) = fft(s_temp, NF);
    %     s_mtd(i,:)=fftshift(fft(s_temp,NF));
end

s_mtd_real = real(s_mtd);
s_mtd_imag = imag(s_mtd);
figure();
mesh(1:NF, 1:Len_Pulse, abs(s_mtd));
xlabel('频率单元'); ylabel('距离单元'); title('MATLAB FFT');

% %%%******写test经MATLAB FFT后的数据到.txt文件******
% Signal_FFT_real=fix(s_mtd_real');              % real
% Signal_FFT_imag=fix(s_mtd_imag');              % imag
% Signal_FFT_real(find(Signal_FFT_real<0))=Signal_FFT_real(find(Signal_FFT_real<0))+2^20;    % 负数转换成补码
% Signal_FFT_imag(find(Signal_FFT_imag<0))=Signal_FFT_imag(find(Signal_FFT_imag<0))+2^20;
% fid_real=fopen('data_out_check_real_MATLAB_matrix.txt','wt');
% fid_imag=fopen('data_out_check_imag_MATLAB_matrix.txt','wt');
% fprintf(fid_real,'%x\n',Signal_FFT_real);
% fprintf(fid_imag,'%x\n',Signal_FFT_imag);
% fclose(fid_real);
% fclose(fid_imag);

% a=8;                   % N个多普勒单元
% for i=0:3
%     figure();
%   for k=1:8
%       subplot(2,4,k), plot(1:Len_Pulse,s_mtd(:,k+i*a));
%   end
% end

% [z,xi_max]=max(s_mtd);
% [zmax,yi_max]=max(z);
