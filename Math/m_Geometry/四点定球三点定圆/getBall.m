function [Func,Mu,R]=getBall(X,Y,Z)
syms x y z
symMat=[x.^2+y.^2+z.^2,x,y,z,1];
varMat=[X(1).^2+Y(1).^2+Z(1).^2,X(1),Y(1),Z(1),1;
        X(2).^2+Y(2).^2+Z(2).^2,X(2),Y(2),Z(2),1;
        X(3).^2+Y(3).^2+Z(3).^2,X(3),Y(3),Z(3),1;
        X(4).^2+Y(4).^2+Z(4).^2,X(4),Y(4),Z(4),1];

% 计算球隐函数
Func=matlabFunction(det([symMat;varMat]));

% 计算各个参数
a=det([1 0 0 0 0;varMat]);
b=det([0 1 0 0 0;varMat]);
c=det([0 0 1 0 0;varMat]);
d=det([0 0 0 1 0;varMat]);
e=det([0 0 0 0 1;varMat]);

% 计算球心，半径等信息
Mu=-[b,c,d]./a./2;
R=sqrt(sum(Mu.^2)-e./a);
end
