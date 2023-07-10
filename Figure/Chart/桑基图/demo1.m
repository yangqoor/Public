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
axis([0,2,0,1])
sankeyHdl=sankey2([],'XLim',[0,2],'YLim',[0,1],'PieceWidth',0.15,'List',List,'Color',[0.3,0.3,0.7])

sankeyHdl.block(4).FaceColor=[0.8,0.3,0.3];

sankeyHdl.connect(10,1).FaceColor=[0.8,0.3,0.3];

sankeyHdl.txt(11).FontSize=40;
 