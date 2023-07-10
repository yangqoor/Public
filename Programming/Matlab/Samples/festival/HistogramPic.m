function HistogramPic
pic=imread('1.jpg');
%pic=rgb2gray(pic);

FreqNum=zeros(size(pic,3),256);
for i=1:size(pic,3)
    for j=0:255
        FreqNum(i,j+1)=sum(sum(pic(:,:,i)==j));
    end
end

ax=gca;
hold(ax,'on')

if size(FreqNum,1)==3
    rBar=bar(0:255,FreqNum(1,:));
    gBar=bar(0:255,FreqNum(2,:));
    bBar=bar(0:255,FreqNum(3,:));
    rBar.FaceColor=[0.6350 0.0780 0.1840];
    gBar.FaceColor=[0.2400 0.5300 0.0900];
    bBar.FaceColor=[0      0.4470 0.7410];
    rBar.FaceAlpha=0.5;
    gBar.FaceAlpha=0.5;
    bBar.FaceAlpha=0.5;
    ax.XLabel.String='RGB brightness';
    
    rrange=find(FreqNum(1,:)~=0);
    rrange=[num2str(rrange(1)-1),' , ',num2str(rrange(end)-1)];
    grange=find(FreqNum(2,:)~=0);
    grange=[num2str(grange(1)-1),' , ',num2str(grange(end)-1)];
    brange=find(FreqNum(3,:)~=0);
    brange=[num2str(brange(1)-1),' , ',num2str(brange(end)-1)];
    legend({['R: range[',rrange,']'],...
            ['G: range[',grange,']'],...
            ['B: range[',brange,']']},...
             'Location','northwest','Color',[0.9412    0.9412    0.9412],...
             'FontName','Cambria','LineWidth',0.8,'FontSize',11);
else 
    kBar=bar(0:255,FreqNum(1,:));
    kBar.FaceColor=[0.50 0.50 0.50];
    kBar.FaceAlpha=0.5;
    ax.XLabel.String='Gray scale';
    krange=find(FreqNum(1,:)~=0);
    krange=[num2str(krange(1)-1),' , ',num2str(krange(end)-1)];
    legend(['Gray: range[',krange,']'],...
           'Location','northwest','Color',[0.9412    0.9412    0.9412],...
           'FontName','Cambria','LineWidth',0.8,'FontSize',11);
end
box on
grid on
ax.LineWidth = 1;
ax.GridLineStyle='--';
ax.XLim=[-5 255];
ax.XTick=[0:45:255,255];


ax.XLabel.FontSize=13;
ax.XLabel.FontName='Cambria';

ax.YLabel.String='Frequency number';
ax.YLabel.FontSize=13;
ax.YLabel.FontName='Cambria';
end
