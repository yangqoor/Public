
% 输入: inputCfarResMat - 进行峰值聚焦的二维矩阵,即进行range维CFAR判决后得到的结果矩阵
% 输出: row - 物体的行坐标(对应速度)
% column - 物体的列坐标(对应距离)

function [row,column] = peakFocus(inputCfarResMat,detMatrix)
    j      = 1;
    row    = zeros([1 96]);
    column = zeros([1 96]);
    [d,r]  = find(inputCfarResMat>0);   %寻找进行range维cfar后的判决为1的坐标
    row    = d;
    column = r;
    
end
