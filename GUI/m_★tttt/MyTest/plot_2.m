% 计算两条线的交点及三角形垂心
% 为了让整个流程比较完整，
% 1、我用了12个点，每两个点一条线，能组成6条线；
% 2、每两条线相交于一点，一共有3个点；
% 3、3个点构成了三角形的三个顶点，然后再根据三个顶点计算三角形的垂心。

X = [294.94, 668.61, 1678.70, 1731.25, 540.16, 1731.25, 335.80, 1696.22, 1106.51, 1404.28, 1351.74, 1591.12];  
Y = [2959.12, 1464.42, 2848.19, 1914.00, 1978.22, 1919.83, 2778.12, 2678.86, 892.23, 1832.25, 880.56, 1820.58];
plot(X, Y, '.');

for i = 1: 6
    plot([X(2*i-1), X(2*i)], [Y(2*i-1), Y(2*i)]);
    hold on;
end
%全部直线的方程式
a = zeros(6, 1);
b = zeros(6, 1);
for i = 1: 6
    a(i, 1) = (Y(2*i) - Y(2*i-1)) / (X(2*i) - X(2*i-1));
    b(i, 1) = Y(2*i) - a(i, 1) * X(2*i);
end
%两两之间的交点
points = zeros(3, 2);
for i = 1: 3
    % 两个直线方程之差的函数
    fun = @(x) (a(2*i-1, 1) * x + b(2*i-1, 1)) - (a(2*i, 1) * x + b(2*i, 1));
    
    % 两个直线方程之差函数值为0时的x值，由得到的x值计算y值
    points(i, 1) = fzero(fun, 2);
    points(i, 2) = a(2*i) * points(i, 1) + b(2*i, 1);
end

hold on;
plot([points(:, 1); points(1, 1)], [points(:, 2); points(1, 2)])

% 计算各个顶点连线的方程式
slope1_2 = (points(2, 2) - points(1, 2)) / (points(2, 1) - points(1, 1));
slope2_3 = (points(3, 2) - points(2, 2)) / (points(3, 1) - points(2, 1));
slope1_3 = (points(3, 2) - points(1, 2)) / (points(3, 1) - points(1, 1));
b1_2 = points(2, 2) - slope1_2 * points(2, 1);
b2_3 = points(3, 2) - slope2_3 * points(3, 1);
b1_3 = points(1, 2) - slope1_3 * points(1, 1);
slopevertical1_2 = -1 / slope1_2;
slopevertical2_3 = -1 / slope2_3;
slopevertical1_3 = -1 / slope1_3;

verticalb1_2 = points(3, 2) - slopevertical1_2 * points(3, 1);
verticalb2_3 = points(1, 2) - slopevertical2_3 * points(1, 1);
verticalb1_3 = points(2, 2) - slopevertical1_3 * points(2, 1);

% 设置预绘制直线的两个端点的X值
verticalLinePoints = zeros(6, 2)
for i = 1: 3
    verticalLinePoints(2*i-1, 1) = 0;
    verticalLinePoints(2*i, 1) = 10000;
    if i == 1
         slopevertical = slopevertical1_2;
         verticalb = verticalb1_2;
    elseif i == 2
         slopevertical = slopevertical2_3;
         verticalb = verticalb2_3;
    else
	 slopevertical = slopevertical1_3;
	 verticalb = verticalb1_3;
    end
    
   % 计算两个端点的y值
    verticalLinePoints(2*i-1, 2) = slopevertical * verticalLinePoints(2*i-1, 1) + verticalb;
    verticalLinePoints(2*i, 2) = slopevertical * verticalLinePoints(2*i, 1) + verticalb;
end

hold on;	% 为了保留前面绘制的图像，使用hold on
plot(verticalLinePoints(1:2, 1), verticalLinePoints(1:2, 2));
plot(verticalLinePoints(3:4, 1), verticalLinePoints(3:4, 2));
plot(verticalLinePoints(5:6, 1), verticalLinePoints(5:6, 2));
axis equal;%axis square/将当前坐标系图形设置为方形  axis equal/将横轴纵轴的定标系数设成相同值