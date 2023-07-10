clear;clc;

%--------------------------------------------------------------------------
%   可视化
%--------------------------------------------------------------------------
figure(1)
load leak_power-40dB.mat
semilogy(snr_scale,rms_out);grid on;
hold on
%--------------------------------------------------------------------------
load leak_power-35dB.mat
semilogy(snr_scale,rms_out);grid on;
%--------------------------------------------------------------------------
load leak_power-30dB.mat
semilogy(snr_scale,rms_out);grid on;
%--------------------------------------------------------------------------
load leak_power-25dB.mat
semilogy(snr_scale,rms_out);grid on;
%--------------------------------------------------------------------------
load leak_power-20dB.mat
semilogy(snr_scale,rms_out);grid on;
%--------------------------------------------------------------------------
load leak_power-15dB.mat
semilogy(snr_scale,rms_out);grid on;
%--------------------------------------------------------------------------
load leak_power-10dB.mat
semilogy(snr_scale,rms_out);grid on;
%--------------------------------------------------------------------------
hold off

xlabel('信噪比');ylabel('RMSE');title('LFM信号通道泄露')
legend('-40dB','-35dB','-30dB','-25dB','-20dB','-15dB','-10dB')