List={'a1',1,'A';
      'a2',1,'A';
      'a3',1,'A';
      'a3',0.5,'C';
      'b1',1,'B';
      'b2',1,'B';
      'b3',1,'B';
      'c1',1,'C';
      'c2',1,'C';
      'c3',1,'C';
      'A',2,'AA';
      'A',1,'BB';
      'B',1.5,'BB';
      'B',1.5,'AA';
      'C',3.5,'BB';
      };
axis([0,1.8,0,1]) 
colorList=[0.4600    0.5400    0.4600
    0.5400    0.6800    0.4600
    0.4100    0.4900    0.3600
    0.3800    0.5300    0.8400
    0.4400    0.5900    0.8700
    0.5800    0.7900    0.9300
    0.6500    0.6400    0.8400
    0.6300    0.6300    0.8000
    0.5600    0.5300    0.6700
    0.7600    0.8100    0.4300
    0.5600    0.8600    0.9700
    0.7800    0.5900    0.6500
    0.8900    0.9100    0.5300
    0.9300    0.5600    0.2500];
sankeyHdl=sankey2([],'XLim',[0,2],'YLim',[0,1],'PieceWidth',0.05,'List',List,'Color',colorList) 

% 调整字体
for i=1:length(sankeyHdl.txt)
    sankeyHdl.txt(i).FontName='Cambria';
    sankeyHdl.txt(i).FontSize=13;
end

% 调整方块颜色
for i=1:length(sankeyHdl.block)
    sankeyHdl.block(i).FaceColor=[1,1,1].*.35;
end

% 坐标区域修饰
ax=gca;box on
ax.Color=[245,245,245]./255;
ax.LineWidth=2;
ax.XColor=[1,1,1].*.3;
ax.YColor=[1,1,1].*.3;
ax.FontName='Cambria';
ax.FontSize=12;