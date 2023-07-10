%   自己设计的二维直方图最大熵法
%   算法参考文献: 龚坚,李立源,陈维南. 二维熵阈值分割的快速算法. 东南大学学报,1996,26(4):31-36
%   曹力,史忠科. 基于最大熵原理的多阈值自动选取新方法. 中国图象图形学报, 2002, 7(A):461-465.
%   利用等概率场熵最大的原理求解阈值
function [Th, segImg] = My2D_Entropy(cX, N)
    [m, n] = size(cX);

    cX = double(cX);

    %计算原图象的8邻域灰度图
    myfilt = [1/8, 1/8, 1/8; 1/8, 0, 1/8; 1/8, 1/8, 1/8];
    g = round(filter2(myfilt, cX));

    %构建二维直方图
    h_2d = zeros(256); %初始化

    for i = 1:m

        for j = 1:n
            r = cX(i, j) + 1;
            c = g(i, j) + 1;
            h_2d(r, c) = h_2d(r, c) + 1;
        end

    end

    %归一化直方图
    p = h_2d / (m * n);

    Ps = cumsum(cumsum(p, 1), 2);

    %初始化输出
    Th = zeros(N - 1, 1);
    En = Th;

    for i = 1:N - 1
        temp = abs(Ps - i / N);
        %求出最大值所在的行
        [MinRow, RowIndex] = min(temp);
        %求出最大值所在的列
        [MinCol, ColIndex] = min(MinRow);
        S = ColIndex;
        Th(i) = RowIndex(S);
        En(i) = MinCol;
    end

    %对阈值进行排序
    Th = sort(Th);

    segImg = zeros(m, n);

    %     temp=zeros(m,n);

    for i = 1:N - 2
        temp = cX > Th(i) & cX <= Th(i + 1);

        if (~isempty(temp))
            segImg = segImg + i * temp;
        end

    end

    temp = cX > Th(N - 1);

    if (~isempty(temp))
        segImg = segImg + (N - 1) * (cX > Th(N - 1));
    end
