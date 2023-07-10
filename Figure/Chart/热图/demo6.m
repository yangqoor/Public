% demo6

Data=rand(3,12);
SHM=SHeatmap(Data,'Format','sq');
SHM=SHM.draw();

CB=colorbar;
CB.Location='southoutside';
