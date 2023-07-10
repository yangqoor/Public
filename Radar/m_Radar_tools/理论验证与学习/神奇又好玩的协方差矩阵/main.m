clear;clc;format longG

%--------------------------------------------------------------------------
%   一组标准的概率分布，构造一个二维数据
%--------------------------------------------------------------------------

x = 3.*randn(1,1000);
y = 1.*randn(1,1000);

A = [x;y];

A = rotate_2d(0)*A;


Rxx = A*A'/1000;
[V,D] = eig(Rxx)

figure(1)
plot(A(1,:),A(2,:),'x');grid on;axis equal;hold on;
quiver(0,0,V(1,1).*sqrt(D(1,1)),V(2,1).*sqrt(D(1,1)),'LineWidth',3)
quiver(0,0,V(1,2)*sqrt(D(2,2)),V(2,2)*sqrt(D(2,2)),'LineWidth',3)

hold off