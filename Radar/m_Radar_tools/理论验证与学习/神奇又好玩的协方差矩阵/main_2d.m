clear;clc;format longG

%--------------------------------------------------------------------------
%   一组标准的概率分布，构造一个二维数据
%--------------------------------------------------------------------------

N = 1000;
x = 1.*randn(1,N);
y = 1.*randn(1,N);

D = [x;y];
T = rotate_2d(40)*[4 0;0 1];
new_D = T*D;


Rxx = new_D*new_D'./(N-1);
[V,D] = eig(Rxx)

figure(1)
plot(new_D(1,:),new_D(2,:),'.');grid on;axis equal;hold on;
quiver(0,0,V(1,1).*sqrt(D(1,1)),V(2,1).*sqrt(D(1,1)),'LineWidth',3)
quiver(0,0,V(1,2)*sqrt(D(2,2)),V(2,2)*sqrt(D(2,2)),'LineWidth',3)

legend('数据分布','特征向量1','特征向量2')
hold off