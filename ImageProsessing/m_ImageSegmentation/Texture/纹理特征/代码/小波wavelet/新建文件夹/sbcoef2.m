function b = sbcoef2(c, s, n)
% SBCOEF2 Extract 2-D subband coefficients 提取2维子带系数
%	B = SBCOEF2(C, S, N)
%
% Input:
%	[C, S]:	wavelet decomposition structure (see WAVEDEC2)
%	N:	subband number, 0 for approximation, 0表示低通波段
%		1 for H(K), 2 for V(K), 3 for D(K), 4 for H(K-1), ...
%		where K is number of wavelet decomposition levelsK为小波分解级数
%
% Output:
%	B:	subband coefficents (in a vector)

if n == 0
    b = c(1:s(1,1)*s(1,2));
else
   q = floor((n-1) / 3);%其分解尺度，从0开始
   r = n - 1 - 3*q;%方向

   length = s(q+2,1)*s(q+2,2);%该方向分解的大小
   first  = s(1,1)*s(1,2) + 3*sum(s(2:q+1,1).*s(2:q+1,2)) + r*length + 1;%每个尺度下其三个方向子带大小是相等的
   last   = first + length - 1;

   b = c(first:last);
end
