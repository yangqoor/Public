Data=rand(12,12)-.5;
Data([4,5,13])=nan;

SHM=SHeatmap(Data,'Format','sq');
SHM=SHM.draw();


colormap(slanCM(97))
SHM.setText();
