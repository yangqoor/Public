% demo2

Data=rand(10,10);
SHM=SHeatmap(Data,'Format','sq');
SHM=SHM.draw(); 

ax=gca;
ax.XTickLabel={'X-1','X-2','X-3','X-4','X-5','X-6','X-7','X-8','X-9','X-10'};
ax.YTickLabel={'Y-1','Y-2','Y-3','Y-4','Y-5','Y-6','Y-7','Y-8','Y-9','Y-10'};
ax.FontSize=14;