%   基于最大熵原理的阈值法
%   算法参考文献: 曹力,史忠科. 基于最大熵原理的多阈值自动选取新方法. 中国图象图形学报, 2002, 7(A):461-465.
%   输入参数:   cX--灰度图像或低频小波子图
%               N--分类数
%   输出: th--分割的最佳阈值,为一一维数组,大小为N
%         en--分割时的最优熵
function [Th,segImg] = entropy(cX,N)
%   获得图像行数和列数值
    [row,col]=size(cX);
%   统计并返回各个灰度等级像素个数并进行归一化处理,获得各灰度等级概率
    h=imhist(cX)/row/col;
    
%   初始化返回值
    Th=zeros(N-1,1);
    en=Th;

%   对直方图进行累加
    pA=cumsum(h);
%   按信息熵原理计算熵值
    for i=1:N-1
        [Th(i),en(i)]=min(abs(pA-i/N));
    end
    
    %对或值进行排序
    Th=sort(Th);
    
    segImg=zeros(row,col);
    
%     temp=zeros(row,col);
    
    for i=1:N-2
        temp=cX>Th(i) & cX<=Th(i+1);
        if(~isempty(temp))
            segImg=segImg+i*temp;
        end
    end
    temp=cX>Th(N-1);
    if(~isempty(temp))
        segImg=segImg+(N-1)*(cX>Th(N-1));
    end
