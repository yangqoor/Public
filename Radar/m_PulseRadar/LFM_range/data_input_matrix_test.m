%%%%&&&&&&&& Xilinx FFT IP Core���� &&&&&&&&
%%# ˵���������г���1������Test Data of FPGA ��ִ�С�2��֮ǰ�����ظ����С�1������2���ǱȽ�FPGA��MATLAB�� FFT
% MATLAB����FPGA��������/������ܲ���
%%%��1��****** input data(matrix) test for FFT IP Core******
clc;
clear all;
close all;

%%%******Initialize Parameters******
Amplitude = 1;                                         % �źŷ���
sigma_2 = 0.1;                                         % ��������
Len_Pulse = 1000;                                      % ���뵥Ԫ��(һ���������ݳ���)
N = 32;                                                % �������
fr = 10e3;                                             % �����ظ�Ƶ��
tr = 1 / fr;
fs = 1e7;                                              % ����Ƶ��(fs=fr*Len_Pulse)
ts = 1 / fs;
fd = 1e3;                                              % ������Ƶ��

%%%******�����״�ز��ź�******
n = 1:Len_Pulse * N;
echo_pulse = [zeros(1, 100), 1, 1, zeros(1, Len_Pulse - 102)];
echo_pulse_N = repmat(echo_pulse, 1, N);               % ����
Signal_N = Amplitude * exp(1i * 2 * pi * fd * ts * n); % �����ź�
noise_I = sqrt(sigma_2) * randn(1, Len_Pulse * N);
noise_Q = sqrt(sigma_2) * randn(1, Len_Pulse * N);
noise_N = noise_I + 1i * noise_Q;                      % noise
% Signal=ones(1,Len_Pulse*N);
Signal = Signal_N .* echo_pulse_N + noise_N;           % N�������״�ز��ź�

% %%%******дtest���ݵ�.txt�ļ�******
% Signal_test=fix(Signal*2^10);    % input data test
% Signal_test_real=fix(real(Signal_test));              % real
% Signal_test_imag=fix(imag(Signal_test));              % imag
% Signal_test_real(find(Signal_test_real<0))=Signal_test_real(find(Signal_test_real<0))+2^20;  % ����ת���ɲ���
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
% title('�״�ز��ź�')
% subplot(2,1,2),  plot(n,Signal);
% title('N�������״�ز��ź�(������)');

Signal_matrix = reshape(Signal, Len_Pulse, N); % ���ݾ���(Len_Pulse�����뵥Ԫ,N������)
% figure();
% plot(1:Len_Pulse,Signal_matrix(:,1));

NF = 32; % NF��FFT

for i = 1:Len_Pulse % �������˲�����
    s_temp = Signal_matrix(i, :);
    s_mtd(i, :) = fft(s_temp, NF);
    %     s_mtd(i,:)=fftshift(fft(s_temp,NF));
end

s_mtd_real = real(s_mtd);
s_mtd_imag = imag(s_mtd);
figure();
mesh(1:NF, 1:Len_Pulse, abs(s_mtd));
xlabel('Ƶ�ʵ�Ԫ'); ylabel('���뵥Ԫ'); title('MATLAB FFT');

% %%%******дtest��MATLAB FFT������ݵ�.txt�ļ�******
% Signal_FFT_real=fix(s_mtd_real');              % real
% Signal_FFT_imag=fix(s_mtd_imag');              % imag
% Signal_FFT_real(find(Signal_FFT_real<0))=Signal_FFT_real(find(Signal_FFT_real<0))+2^20;    % ����ת���ɲ���
% Signal_FFT_imag(find(Signal_FFT_imag<0))=Signal_FFT_imag(find(Signal_FFT_imag<0))+2^20;
% fid_real=fopen('data_out_check_real_MATLAB_matrix.txt','wt');
% fid_imag=fopen('data_out_check_imag_MATLAB_matrix.txt','wt');
% fprintf(fid_real,'%x\n',Signal_FFT_real);
% fprintf(fid_imag,'%x\n',Signal_FFT_imag);
% fclose(fid_real);
% fclose(fid_imag);

% a=8;                   % N�������յ�Ԫ
% for i=0:3
%     figure();
%   for k=1:8
%       subplot(2,4,k), plot(1:Len_Pulse,s_mtd(:,k+i*a));
%   end
% end

% [z,xi_max]=max(s_mtd);
% [zmax,yi_max]=max(z);
