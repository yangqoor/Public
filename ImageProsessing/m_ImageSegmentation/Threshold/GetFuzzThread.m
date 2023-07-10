%   ģ����ֵ�ָ��㷨
%   �ο�����: �¹�,��鸣. ͼ�������Ӧģ����ֵ�ָ. �Զ���ѧ��,2003,29(5),791-796
%   �������:
%       X: ͼ������,   dq: ����
%   �������
%       Thread: ��ֵ, W:
function [Thread,SegImg]=GetFuzzThread(X,dq)

[m,n]=size(X);
H=imhist(X);

MN=m*n;
%����ֱ��ͼ�Ĵ�С
HLength=length(H);

W=zeros(HLength,1);

for i=1:HLength;
    U=S(i,dq,HLength);
    W(i)=Gama(H,U,MN,HLength);
end;

[ans,Thread]=min(W);

SegImg=(X>Thread);
end

%ͼ��X��ģ���ʦ�(X)�Ƕ�ͼ���ģ���Զ���,��h(k)Ϊͼ��X�лҶ�ȡk�����ظ���,���(X) ��������:
%��(X) =2/MN *��T(k)*h(k)
%����T(k) = min(��k , 1-��k) .

function Yx=Gama(H,U,MN,HLen)

T=(U<=0.5).*U +(U>0.5).*(ones(HLen,1)-U);

Yx=sum(T.*H)/MN*2;

end

%S����,��
%��x =
% 		0 , 0 �� x �� q - ��q
% 		2 [(x - q +��q) / 2��q ]^2 , q - ��q �� x �� q
% 		1 - 2[( x - q - ��q) / 2��q ]^2 , q < x �� q + ��q
% 		1 , q +��q < x �� L
function Ux=S(q,dq,HLen)

x=[1:HLen]';
x=double(x);
q=double(q);
dq=double(q);

Ux=((x>(q-dq)).*(x<=q)).*(((x-ones(HLen,1)*(q-dq))/dq).^2/2) +((x>q).*(x<=q+dq)).*(ones(HLen,1)-(((x-ones(HLen,1)*(q+dq))/dq).^2/2)) +(x>(q+dq));

end
