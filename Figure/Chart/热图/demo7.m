% demo7

figure()
Data=rand(9,9);
Data([4,5,13])=nan;

SHM=SHeatmap(Data,'Format','sq');
SHM=SHM.draw();

SHM.setText(); 

for i=1:size(Data,1)
    for j=1:size(Data,2)
        if Data(i,j)>.9
            SHM.setTextMN(i,j,'String','**','FontSize',20)
            SHM.setPatchMN(i,j,'EdgeColor',[1,0,0],'LineWidth',2)
        end
    end
end

SHM.setPatchMN(4,1,'FaceColor',[.8,.6,.6])