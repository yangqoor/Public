% demo 4

figure()
Data=rand(10,10);
Data([4,5,13])=nan;

SHM=SHeatmap(Data,'Format','pie');
SHM=SHM.draw(); 

SHM.setBox('Color',[0,0,.8])
SHM.setPatch('EdgeColor',[.8,0,0])


figure()
Data=rand(10,10);
Data([4,5,13])=nan;

SHM=SHeatmap(Data,'Format','sq');
SHM=SHM.draw(); 

SHM.setText('Color',[0,0,.8],'FontSize',14)