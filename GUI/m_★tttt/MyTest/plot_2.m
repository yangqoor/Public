% ���������ߵĽ��㼰�����δ���
% Ϊ�����������̱Ƚ�������
% 1��������12���㣬ÿ������һ���ߣ������6���ߣ�
% 2��ÿ�������ཻ��һ�㣬һ����3���㣻
% 3��3���㹹���������ε��������㣬Ȼ���ٸ�������������������εĴ��ġ�

X = [294.94, 668.61, 1678.70, 1731.25, 540.16, 1731.25, 335.80, 1696.22, 1106.51, 1404.28, 1351.74, 1591.12];  
Y = [2959.12, 1464.42, 2848.19, 1914.00, 1978.22, 1919.83, 2778.12, 2678.86, 892.23, 1832.25, 880.56, 1820.58];
plot(X, Y, '.');

for i = 1: 6
    plot([X(2*i-1), X(2*i)], [Y(2*i-1), Y(2*i)]);
    hold on;
end
%ȫ��ֱ�ߵķ���ʽ
a = zeros(6, 1);
b = zeros(6, 1);
for i = 1: 6
    a(i, 1) = (Y(2*i) - Y(2*i-1)) / (X(2*i) - X(2*i-1));
    b(i, 1) = Y(2*i) - a(i, 1) * X(2*i);
end
%����֮��Ľ���
points = zeros(3, 2);
for i = 1: 3
    % ����ֱ�߷���֮��ĺ���
    fun = @(x) (a(2*i-1, 1) * x + b(2*i-1, 1)) - (a(2*i, 1) * x + b(2*i, 1));
    
    % ����ֱ�߷���֮���ֵΪ0ʱ��xֵ���ɵõ���xֵ����yֵ
    points(i, 1) = fzero(fun, 2);
    points(i, 2) = a(2*i) * points(i, 1) + b(2*i, 1);
end

hold on;
plot([points(:, 1); points(1, 1)], [points(:, 2); points(1, 2)])

% ��������������ߵķ���ʽ
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

% ����Ԥ����ֱ�ߵ������˵��Xֵ
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
    
   % ���������˵��yֵ
    verticalLinePoints(2*i-1, 2) = slopevertical * verticalLinePoints(2*i-1, 1) + verticalb;
    verticalLinePoints(2*i, 2) = slopevertical * verticalLinePoints(2*i, 1) + verticalb;
end

hold on;	% Ϊ�˱���ǰ����Ƶ�ͼ��ʹ��hold on
plot(verticalLinePoints(1:2, 1), verticalLinePoints(1:2, 2));
plot(verticalLinePoints(3:4, 1), verticalLinePoints(3:4, 2));
plot(verticalLinePoints(5:6, 1), verticalLinePoints(5:6, 2));
axis equal;%axis square/����ǰ����ϵͼ������Ϊ����  axis equal/����������Ķ���ϵ�������ֵͬ