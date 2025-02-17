%--------------------------------------------------------------------------
%   频率因子阵
%--------------------------------------------------------------------------
%   输入:
%   M           fft的点数
%   L           滤波器的抽头数
%   A           输出矩阵A,即为傅里叶变换的矩阵形式
%--------------------------------------------------------------------------
%   描述：右乘以一个列向量即可实现时域的傅里叶变换
%--------------------------------------------------------------------------
function A = matrix_ml(M,L)
A = zeros(M,L);
for m = 0:M-1
    for l = 0:L-1
        A(m+1,l+1) = exp(-1j*2*pi*m*l/M);
    end
end