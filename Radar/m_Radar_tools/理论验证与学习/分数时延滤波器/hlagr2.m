function h = hlagr2(L,x)
% HLAGR2
% MATLAB m-file for fractional delay approximation
% 拉格朗日插值法的实现函数
% by LAGRANGE INTERPOLATION method
% h = hlagr2(L,x) returns a length L (real) FIR
% filter which approximates the fractional delay
% of x samples.
% Input: L = filter length (filter order N = L-1)
%        x = fractional delay (0 < x <= 1)
% Output: Filter coefficient vector h(1)...h(L)
% Subroutines: standard MATLAB functions

N = L-1;                                                                    % filter order
M = N/2;                                                                    % middle value
if (M-round(M))==0 
    D= x + M;                                                               % integer part closest to middle
else
    D= x + M - 0.5;
end
%
h=ones(1,N+1);
%
for n=0:N          
    n1=n+1;
    for k=0:N
        if (k~=n)
            h(n1) = h(n1)*(D-k)/(n-k);
        end
    end
end