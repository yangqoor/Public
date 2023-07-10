function [Func,Mu,R]=getCircle(X,Y)
syms x y
symMat=[x.^2+y.^2,x,y,1];
varMat=[X(1).^2+Y(1).^2,X(1),Y(1),1;
        X(2).^2+Y(2).^2,X(2),Y(2),1;
        X(3).^2+Y(3).^2,X(3),Y(3),1];

% ����Բ������
Func=matlabFunction(det([symMat;varMat]));

% �����������
a=det([1 0 0 0;varMat]);
b=det([0 1 0 0;varMat]);
c=det([0 0 1 0;varMat]);
d=det([0 0 0 1;varMat]);

% ����Բ�ģ��뾶����Ϣ
Mu=-[b,c]./a./2;
R=sqrt(sum(Mu.^2)-d./a);
end
