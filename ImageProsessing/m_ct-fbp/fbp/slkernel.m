function u = slkernel(t)

u = zeros(size(t));
i1 = abs(abs(t)-pi/2)<=1.e-6;
u(i1) = ones(size(u(i1)))/pi;
t1 = t(abs(abs(t)-pi/2)>1.e-6);

v = (pi/2 - t1.*sin(t1))./((pi/2)^2 - t1.^2);
u(abs(abs(t)-pi/2)>1.e-6) = v;
u = u/(2*pi^3);
% plot(t1,u);
%xlim([-50 50]);
%title('Shepp-Logan filter');