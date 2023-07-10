%--------------------------------------------------------------------------
%   matlab自带滤波器与手写滤波器功能验证
%--------------------------------------------------------------------------
clear;clc;

%--------------------------------------------------------------------------
%   手写matlab滤波器实现matlab filter函数的效果
%   并增加自动延迟切点功能，验证切点个数
%--------------------------------------------------------------------------
fs = 400e6;
sig = real(rt.exp_wave(1e-6,50e6,fs));
LP = LP_filter_N33;
N = numel(LP.Numerator)
sig_filter = filter(LP,sig);
sig_conv = conv(LP.Numerator,sig);
plot(sig);hold on;
plot(sig_filter,'LineWidth',2)
plot(sig_conv,'--');grid on;hold off

%   N =20 首尾多了19个点