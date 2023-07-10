image = imread('mri1.jpg');
I = rgb2gray(image);
figure, imshow(I), title('原始图像')
I = double(I) / 255;
[M, N] = size(I);
x1 = 65; y1 = 56; x2 = 72; y2 = 113;
seed1 = I(x1, y1);               %将生长起始点灰度值存入seed中
seed2 = I(x2, y2);
Y = zeros(M, N);                 %作一个全零与原图像等大的图像矩阵Y，作为输出图像矩阵
Z = zeros(M, N);
Y(x1, y1) = I(x1, y1);           %将Y中与所取点相对应位置的点设置为与原图像相同的灰度
Z(x2, y2) = I(x2, y2);           %将Z中与所取点相对应位置的点设置为与原图像相同的灰度

sum1 = seed1;                    %储存符合区域生长条件的点的灰度值的和
suit1 = 1;                       %储存符合区域生长条件的点的个数
count1 = 1;                      %记录每次判断一点周围八点符合条件的新点的数目
threshold1 = 0.05555;            %判断域值

while count1 > 0
    s1 = 0;                      %记录判断一点周围八点时，符合条件的新点的灰度值之和
    count1 = 0;

    for i1 = 1:M

        for j1 = 1:ceil(N / 2)

            if Y(i1, j1) ~= 0

                if (i1 - 1) > 0 && (i1 + 1) < (M + 1) && (j1 - 1) > 1 && (j1 + 1) < ((ceil(N / 2)) + 1)
                    %判断此点是否为图像边界上的点
                    for u = -1:1 %判断点周围八点是否合和域值条件

                        for v = -1:1 %u,v为偏移量

                            if Y(i1 + u, j1 + v) == 0 && abs(I(i1 + u, j1 + v) - seed1) <= threshold1
                                %判断是否未存在于输出矩阵Y，并且为符合域值条件的点
                                Y(i1 + u, j1 + v) = I(i1 + u, j1 + v); %符合以上两条件即将其在Y中与之位置对应的点设置为白场
                                count1 = count1 + 1; %此次循环新点数增1
                                s1 = s1 + I(i1 + u, j1 + v); %此点的灰度之加入s中
                            end

                        end

                    end

                end

            end

        end

    end

    suit1 = suit1 + count1; %将n加入符合点数计数器中
    sum1 = sum1 + s1; %将s加入符合点的灰度值总合中
    seed1 = sum1 / suit1; %计算新的灰度平均值
end

sum2 = seed2; %储存符合区域生长的的灰度值
suit2 = 1; %储存符合区域生长条件的点的个数
count2 = 1; %记录每次判断一点周围八点符合条件的新点的数目
threshold2 = 0.06255; %域值

while count2 > 0
    s2 = 0; %记录判断一点周围八点时，符合条件的新点的灰度值之和
    count2 = 0;

    for i2 = 1:M

        for j2 = ceil(N / 2):N

            if Z(i2, j2) ~= 0

                if (i2 - 1) > 0 && (i2 + 1) < (M + 1) && (j2 - 1) > (ceil(N / 2)) && (j2 + 1) < (N + 1)
                    %判断此点是否为图像边界上的点
                    for u = -1:1 %判断点周围八点是否合和域值条件

                        for v = -1:1 %u,v为偏移量

                            if Z(i2 + u, j2 + v) == 0 && abs(I(i2 + u, j2 + v) - seed2) <= threshold2
                                %判断是否未存在于输出矩阵Y，并且为符合域值条件的点
                                Z(i2 + u, j2 + v) = I(i2 + u, j2 + v); %符合以上两条件即将其在Y中与之位置对应的点设置为白场
                                count2 = count2 + 1; %此次循环新点数增1
                                s2 = s2 + I(i2 + u, j2 + v); %此点的灰度之加入s中
                            end

                        end

                    end

                end

            end

        end

    end

    suit2 = suit2 + count2; %将n加入符合点数计数器中
    sum2 = sum2 + s2; %将s加入符合点的灰度值总合中
    seed2 = sum2 / suit2; %计算新的灰度平均值
end

figure, imshow(Y + Z), title('分割后白质图像')
