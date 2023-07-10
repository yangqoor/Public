%   模糊阈值分割算法
%   参考文献: 陈果,左洪福. 图像的自适应模糊阈值分割法. 自动化学报,2003,29(5),791-796
%   输入参数:
%       X: 图像数据,   dq: 窗宽
%   输出参数
%       Thread: 阈值, W:
function [Thread,SegImg]=GetFuzzThread(X,dq)

[m,n]=size(X);
H=imhist(X);

MN=m*n;
%计算直方图的大小
HLength=length(H);

W=zeros(HLength,1);

for i=1:HLength;
    U=S(i,dq,HLength);
    W(i)=Gama(H,U,MN,HLength);
end;

[ans,Thread]=min(W);

SegImg=(X>Thread);
end

%图像X的模糊率γ(X)是对图像的模糊性度量,令h(k)为图像X中灰度取k的象素个数,则γ(X) 定义如下:
%γ(X) =2/MN *∑T(k)*h(k)
%其中T(k) = min(μk , 1-μk) .

function Yx=Gama(H,U,MN,HLen)

T=(U<=0.5).*U +(U>0.5).*(ones(HLen,1)-U);

Yx=sum(T.*H)/MN*2;

end

%S函数,即
%μx =
% 		0 , 0 ≤ x ≤ q - Δq
% 		2 [(x - q +Δq) / 2Δq ]^2 , q - Δq ≤ x ≤ q
% 		1 - 2[( x - q - Δq) / 2Δq ]^2 , q < x ≤ q + Δq
% 		1 , q +Δq < x ≤ L
function Ux=S(q,dq,HLen)

x=[1:HLen]';
x=double(x);
q=double(q);
dq=double(q);

Ux=((x>(q-dq)).*(x<=q)).*(((x-ones(HLen,1)*(q-dq))/dq).^2/2) +((x>q).*(x<=q+dq)).*(ones(HLen,1)-(((x-ones(HLen,1)*(q+dq))/dq).^2/2)) +(x>(q+dq));

end
