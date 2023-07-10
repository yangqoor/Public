%--------------------------------------------------------------------------
%   绘制归一化天线方向图
%   均匀线阵
%--------------------------------------------------------------------------
function [L,L_P,L_dB] = L_norm_array_pattern(w,angle_axis)
N = numel(w);
lambda = 1;                                                                 %波长
dd = lambda/2;                                                              %阵元间距d = lambda/2
d = 0:dd:(N-1)*dd;                                                          %构建阵列坐标

idx = 1;
for theta_step = angle_axis
    A = exp(1j.*2*pi*d.'*sind(theta_step));
    L(idx) = w'*A;                                                          %近似选取上一步作为归一化中心
    idx = idx + 1;
end
L = L./max(abs(L));
L_P = abs(L).^2;
L_dB = mag2db(abs(L));