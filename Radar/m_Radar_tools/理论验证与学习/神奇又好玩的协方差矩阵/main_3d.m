clear;clc;format longG

%--------------------------------------------------------------------------
%   一组标准的概率分布，构造一个二维数据
%--------------------------------------------------------------------------
N = 2000;
x = 10.*randn(1,N);
y = 2.*randn(1,N);
z = 3.*randn(1,N);

A = [x;y;z];

A = rotate_zd(0)*rotate_yd(20)*rotate_xd(0)*A;


Rxx = A*A'./(N-1);
[V,D] = eig(Rxx);

figure(1)
plot3(A(1,:),A(2,:),A(3,:),'.');grid on;axis equal;hold on;

quiver3(0,0,0,V(1,1).*sqrt(D(1,1)).*5,V(2,1).*sqrt(D(1,1)).*5,V(3,1).*sqrt(D(1,1)).*5,'LineWidth',2)
quiver3(0,0,0,V(1,2)*sqrt(D(2,2)).*5,V(2,2)*sqrt(D(2,2)).*5,V(3,2)*sqrt(D(2,2)).*5,'LineWidth',2)
quiver3(0,0,0,V(1,3)*sqrt(D(3,3)).*5,V(2,3)*sqrt(D(3,3)).*5,V(3,3)*sqrt(D(3,3)).*5,'LineWidth',2)
hold off