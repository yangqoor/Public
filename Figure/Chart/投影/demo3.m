[~,L]=ode45(@(t,L)Lorenz(t,L),0:.01:100,[1;1;1;10;28;8/3]); 
plot3(L(:,1),L(:,2),L(:,3))
grid on

axProjection3D('XYZ') 

function dL=Lorenz(t,L)
% L=[x;y;z;a;r;b];
% dL=[dx/dt;dy/dt;dz/dt;0,0,0];
% dz/dt=-a*(x-y)
% dy/dt=x*(r-z)-y
% dz/dt=x*y-b*z
dL=zeros([6,1]);
dL(1)=-L(4)*(L(1)-L(2));
dL(2)=L(1)*(L(5)-L(3))-L(2);
dL(3)=L(1)*L(2)-L(6)*L(3);
dL(4:6)=0;
end