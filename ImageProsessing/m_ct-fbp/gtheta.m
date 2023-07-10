% 计算任意位置的椭圆的投影函数
function y=gtheta(ellipse,R,theta1,n)% 1衰减系数 2长轴 3短轴 4中心x坐标 5中心y坐标 6转角
y=zeros(1,n);
alpha=pi*ellipse(6)/180;
theta=pi*theta1/180;
r_alpha=ellipse(2).^2*(cos(theta-alpha)).^2.+ellipse(3).^2*(sin(theta-alpha)).^2;
D_alpha=R-ellipse(4)*cos(theta)-ellipse(5)*sin(theta);
for i=1:n;
    if abs(D_alpha(i)^2) <= r_alpha(i)
        y(i)=2*ellipse(1)*ellipse(2)*ellipse(3)*sqrt(r_alpha(i)-D_alpha(i)^2)/r_alpha(i);
    else
        y(i)=0;
    end
end