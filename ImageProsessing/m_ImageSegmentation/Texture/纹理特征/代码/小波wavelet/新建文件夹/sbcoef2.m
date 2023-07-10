function b = sbcoef2(c, s, n)
% SBCOEF2 Extract 2-D subband coefficients ��ȡ2ά�Ӵ�ϵ��
%	B = SBCOEF2(C, S, N)
%
% Input:
%	[C, S]:	wavelet decomposition structure (see WAVEDEC2)
%	N:	subband number, 0 for approximation, 0��ʾ��ͨ����
%		1 for H(K), 2 for V(K), 3 for D(K), 4 for H(K-1), ...
%		where K is number of wavelet decomposition levelsKΪС���ֽ⼶��
%
% Output:
%	B:	subband coefficents (in a vector)

if n == 0
    b = c(1:s(1,1)*s(1,2));
else
   q = floor((n-1) / 3);%��ֽ�߶ȣ���0��ʼ
   r = n - 1 - 3*q;%����

   length = s(q+2,1)*s(q+2,2);%�÷���ֽ�Ĵ�С
   first  = s(1,1)*s(1,2) + 3*sum(s(2:q+1,1).*s(2:q+1,2)) + r*length + 1;%ÿ���߶��������������Ӵ���С����ȵ�
   last   = first + length - 1;

   b = c(first:last);
end
