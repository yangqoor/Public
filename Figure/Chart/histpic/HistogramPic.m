function HistogramPic(pic)
FreqNum=zeros(size(pic,3),256);
for i=1:size(pic,3)
    for j=0:255
        FreqNum(i,j+1)=sum(sum(pic(:,:,i)==j));
    end
end
ax=gca;hold(ax,'on');box on;grid on
if size(FreqNum,1)==3
    bar(0:255,FreqNum(1,:),'FaceColor',[0.6350 0.0780 0.1840],'FaceAlpha',0.5);
    bar(0:255,FreqNum(2,:),'FaceColor',[0.2400 0.5300 0.0900],'FaceAlpha',0.5);
    bar(0:255,FreqNum(3,:),'FaceColor',[0      0.4470 0.7410],'FaceAlpha',0.5);
    ax.XLabel.String='RGB brightness';
    rrange=[num2str(min(pic(:,:,1),[],[1,2])),' , ',num2str(max(pic(:,:,1),[],[1,2]))];
    grange=[num2str(min(pic(:,:,2),[],[1,2])),' , ',num2str(max(pic(:,:,2),[],[1,2]))];
    brange=[num2str(min(pic(:,:,3),[],[1,2])),' , ',num2str(max(pic(:,:,3),[],[1,2]))];
    legend({['R: range[',rrange,']'],['G: range[',grange,']'],['B: range[',brange,']']},...
             'Location','northwest','Color',[0.9412    0.9412    0.9412],...
             'FontName','Cambria','LineWidth',0.8,'FontSize',11);
else 
    bar(0:255,FreqNum(1,:),'FaceColor',[0.50 0.50 0.50],'FaceAlpha',0.5);
    ax.XLabel.String='Gray scale';
    krange=[num2str(min(pic(:,:,1),[],[1,2])),' , ',num2str(max(pic(:,:,1),[],[1,2]))];
    legend(['Gray: range[',krange,']'],...
           'Location','northwest','Color',[0.9412    0.9412    0.9412],...
           'FontName','Cambria','LineWidth',0.8,'FontSize',11);
end
ax.LineWidth=1;
ax.GridLineStyle='--';
ax.XLim=[-5 255];
ax.XTick=[0:45:255,255];
ax.YLabel.String='Frequency number';
ax.FontName='Cambria';
ax.FontSize=13;
end
