function G=X_Gmrf_ParaG(WinData,Order)
%
% 计算GNMRF参数估计矩阵G
% WinData  计算数据
% Order    Gmrf的阶次
% 邻域结构为：
%          b52   b44   b32   b41'  b51'
%          b43   b22   b12   b21'  b42'      
%          b31   b11    a    b11'  b31'
%          b42   b21   b12'  b22'  b43'
%          b51   b41   b32'  b44'  b52'
%
%  G 是1行N列的向量

cr=(size(WinData,1)+1)/2;   %计算中心元素坐标
order=Order;
switch order
    case 1
        G=[WinData(cr,cr-1)+WinData(cr,cr+1), WinData(cr-1,cr)+WinData(cr+1,cr)           ];
    case 2
        G=[WinData(cr,cr-1)+WinData(cr,cr+1), WinData(cr-1,cr)+WinData(cr+1,cr),...
             WinData(cr-1,cr+1)+WinData(cr+1,cr-1), WinData(cr-1,cr-1)+WinData(cr+1,cr+1)   ];
    case 3
        G=[WinData(cr,cr-1)+WinData(cr,cr+1), WinData(cr-1,cr)+WinData(cr+1,cr),...
             WinData(cr-1,cr+1)+WinData(cr+1,cr-1), WinData(cr-1,cr-1)+WinData(cr+1,cr+1),...
             WinData(cr,cr-2)+WinData(cr,cr+2), WinData(cr-2,cr)+WinData(cr,cr+2)           ];
    case 4
        G=[WinData(cr,cr-1)+WinData(cr,cr+1), WinData(cr-1,cr)+WinData(cr+1,cr),...
             WinData(cr-1,cr+1)+WinData(cr+1,cr-1), WinData(cr-1,cr-1)+WinData(cr+1,cr+1),...
             WinData(cr,cr-2)+WinData(cr,cr+2), WinData(cr-2,cr)+WinData(cr,cr+2),...
             WinData(cr+2,cr-1)+WinData(cr-2,cr+1), WinData(cr+1,cr-2)+WinData(cr-1,cr+2),...
             WinData(cr-1,cr-2)+WinData(cr+1,cr+2), WinData(cr-2,cr-1)+WinData(cr+2,cr+1)   ];
    case 5
        G=[WinData(cr,cr-1)+WinData(cr,cr+1), WinData(cr-1,cr)+WinData(cr+1,cr),...
             WinData(cr-1,cr+1)+WinData(cr+1,cr-1), WinData(cr-1,cr-1)+WinData(cr+1,cr+1),...
             WinData(cr,cr-2)+WinData(cr,cr+2), WinData(cr-2,cr)+WinData(cr,cr+2),...
             WinData(cr+2,cr-1)+WinData(cr-2,cr+1), WinData(cr+1,cr-2)+WinData(cr-1,cr+2),...
             WinData(cr-1,cr-2)+WinData(cr+1,cr+2), WinData(cr-2,cr-1)+WinData(cr+2,cr+1),...
             WinData(cr-2,cr+2)+WinData(cr+2,cr-2), WinData(cr-2,cr-2)+WinData(cr+2,cr+2)];
    otherwise 
      disp('GMRF Order Error');
end
