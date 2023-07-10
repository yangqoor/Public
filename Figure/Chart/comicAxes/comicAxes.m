function ax=comicAxes(ax)
% @author:slandarer
% 获取要处理的坐标区域 ====================================================
if ~isempty(ax)
else
    ax=gca;
end
hold(ax,'on')

% 为了保证各部分比例的初始修饰 ============================================
n=1;
for i=length(ax.Children):-1:1
    if strcmp(get(ax.Children(i),'type'),'line')
        ax.Children(i).LineWidth=4+rand();
        lineSet(n)=ax.Children(i);
        n=n+1;
    end
end
n=1;textflag=false;
for i=length(ax.Children):-1:1
    if strcmp(get(ax.Children(i),'type'),'text')
        textflag=true;
        textSet(n)=ax.Children(i);
        n=n+1;
    end
end

if ~isempty(ax.Title.String)
    ax.Title.FontSize=19;
    ax.Title.FontWeight='bold';
    ax.Title.FontName='Comic Sans MS';
    ax.Title.Color=[0.2,0.2,0.2];
end
if ~isempty(ax.XLabel.String)
    ax.XLabel.FontSize=16;
end
if ~isempty(ax.YLabel.String)
    ax.YLabel.FontSize=16;
end
if ~isempty(ax.Legend)
    ax.Legend.AutoUpdate='off';
    ax.Legend.FontSize=13;
    ax.Legend.Title.FontSize=15;
    ax.Legend.Title.FontWeight='bold';
    ax.Legend.Title.FontName='Comic Sans MS';
    ax.Legend.FontWeight='bold';
    ax.Legend.FontName='Comic Sans MS';
    ax.Legend.TextColor=[0.5,0.6,0.3];
    ax.Legend.Box='off';
end

% 网格重绘 ================================================================
if strcmp(ax.XGrid,'on')&&~isempty(ax.XTick)
ax.XGrid='off';
for i=1:length(ax.XTick)
    if ax.XTick(i)~=ax.XLim(1)&&ax.XTick(i)~=ax.XLim(2)
        ySet=linspace(ax.YLim(1),ax.YLim(2),20);
        xSet=ones(1,length(ySet)).*ax.XTick(i)+(rand([1,length(ySet)])-0.5).*(ax.XLim(2)-ax.XLim(1)).*0.006;
        nYSet=linspace(ax.YLim(1),ax.YLim(2),100);
        nXSet=interp1(ySet,xSet,nYSet,'spline');
        plot(ax,nXSet,nYSet,'Color',[0.2 0.2 0.2 0.1],'LineWidth',4)
    end
end
end
if strcmp(ax.YGrid,'on')&&~isempty(ax.YTick)
ax.YGrid='off';
for i=1:length(ax.YTick)
    if ax.YTick(i)~=ax.YLim(1)&&ax.YTick(i)~=ax.YLim(2)
        xSet=linspace(ax.XLim(1),ax.XLim(2),20);
        ySet=ones(1,length(xSet)).*ax.YTick(i)+(rand([1,length(xSet)])-0.5).*(ax.YLim(2)-ax.YLim(1)).*0.006;
        nXSet=linspace(ax.XLim(1),ax.XLim(2),100);
        nYSet=interp1(xSet,ySet,nXSet,'spline');
        plot(ax,nXSet,nYSet,'Color',[0.2 0.2 0.2 0.1],'LineWidth',4)
    end
end
end


% 图像重绘 ================================================================
for i=1:length(lineSet)
    if strcmp(get(lineSet(i),'type'),'line')
        %lineSet(i).Visible='off';
        xSet=linspace(ax.XLim(1),ax.XLim(2),20);
        ySet=(rand([1,length(xSet)])-0.5).*(ax.YLim(2)-ax.YLim(1)).*0.01;
        nYSet=interp1(xSet,ySet,lineSet(i).XData,'spline');
        plot(ax,lineSet(i).XData,lineSet(i).YData+nYSet,'LineWidth',lineSet(i).LineWidth+4.5,'Color',[1 1 1 .9])
        plot(ax,lineSet(i).XData,lineSet(i).YData+nYSet,'LineWidth',lineSet(i).LineWidth,'Color',lineSet(i).Color)
    end
end


% 坐标轴重绘 ==============================================================
ax.XColor='none';
ax.YColor='none';

xSet=linspace(ax.XLim(1),ax.XLim(2),20);
ySet=ones(1,length(xSet)).*ax.YLim(1)+(rand([1,length(xSet)])+0.2).*(ax.YLim(2)-ax.YLim(1)).*0.006;
nXSet=linspace(ax.XLim(1),ax.XLim(2),100);
nYSet=interp1(xSet,ySet,nXSet,'spline');
plot(ax,nXSet,nYSet,'Color',[0.25,0.25,0.25,0.8],'LineWidth',4)
ySet=linspace(ax.YLim(1),ax.YLim(2),20);
xSet=ones(1,length(ySet)).*ax.XLim(1)+(rand([1,length(ySet)])+0.2).*(ax.XLim(2)-ax.XLim(1)).*0.006;
nYSet=linspace(ax.YLim(1),ax.YLim(2),100);
nXSet=interp1(ySet,xSet,nYSet,'spline');
plot(ax,nXSet,nYSet,'Color',[0.25 0.25 0.25,0.8],'LineWidth',4)

if ~isempty(ax.XTick)
for i=1:length(ax.XTick)
    if ax.XTick(i)~=ax.XLim(1)&&ax.XTick(i)~=ax.XLim(2)
    tickLen=1.5*(ax.TickLength(1)/(ax.Position(4))*(ax.YLim(2)-ax.YLim(1)))+rand()*(ax.YLim(2)-ax.YLim(1))*0.01;
    plot(ax,[ax.XTick(i),ax.XTick(i)],[ax.YLim(1),ax.YLim(1)+tickLen],'Color',[0.25,0.25,0.25,0.8],'LineWidth',5);  
    end
    text(ax,ax.XTick(i),ax.YLim(1)-1.2*ax.TickLength(1)/(ax.Position(4))*(ax.YLim(2)-ax.YLim(1)),...
                ax.XTickLabel{i},'HorizontalAlignment','center','FontWeight','bold',...
                'Color',[0.3,0.3,0.3],'FontName','Comic Sans MS','FontSize',12,'VerticalAlignment','top');
end
end
if ~isempty(ax.YTick)
for i=1:length(ax.YTick)
    if ax.YTick(i)~=ax.YLim(1)&&ax.YTick(i)~=ax.YLim(2)
    tickLen=1.5*(ax.TickLength(1)/(ax.Position(3))*(ax.XLim(2)-ax.XLim(1)))+rand()*(ax.XLim(2)-ax.XLim(1))*0.01;
    plot(ax,[ax.XLim(1),ax.XLim(1)+tickLen],[ax.YTick(i),ax.YTick(i)],'Color',[0.25,0.25,0.25,0.8],'LineWidth',5);  
    end
    text(ax,ax.XLim(1)-1.2*ax.TickLength(1)/(ax.Position(3))*(ax.XLim(2)-ax.XLim(1)),...
                ax.YTick(i),ax.YTickLabel{i},'HorizontalAlignment','right','FontWeight','bold',...
                'Color',[0.3,0.3,0.3],'FontName','Comic Sans MS','FontSize',12);
end
end

if strcmp(ax.Box,'on')
    xSet=linspace(ax.XLim(1),ax.XLim(2),20);
    ySet=ones(1,length(xSet)).*ax.YLim(2)-(rand([1,length(xSet)])+0.2).*(ax.YLim(2)-ax.YLim(1)).*0.006;
    nXSet=linspace(ax.XLim(1),ax.XLim(2),100);
    nYSet=interp1(xSet,ySet,nXSet,'spline');
    plot(ax,nXSet,nYSet,'Color',[0.25,0.25,0.25,0.8],'LineWidth',4)
    ySet=linspace(ax.YLim(1),ax.YLim(2),20);
    xSet=ones(1,length(ySet)).*ax.XLim(2)-(rand([1,length(ySet)])+0.2).*(ax.XLim(2)-ax.XLim(1)).*0.006;
    nYSet=linspace(ax.YLim(1),ax.YLim(2),100);
    nXSet=interp1(ySet,xSet,nYSet,'spline');
    plot(ax,nXSet,nYSet,'Color',[0.25,0.25,0.25,0.8],'LineWidth',4)
end

if ~isempty(ax.XLabel.String)
   sepY=(ax.TightInset(2)-ax.Position(2))/ax.Position(4)*(ax.YLim(2)-ax.YLim(1));
   text(ax,(ax.XLim(2)+ax.XLim(1))/2,ax.YLim(1)+sepY,ax.XLabel.String,...
       'HorizontalAlignment','center','FontWeight','bold','VerticalAlignment','cap',...
       'Color',[0.3,0.3,0.3],'FontName','Comic Sans MS','FontSize',16);
end
if ~isempty(ax.YLabel.String)
    sepX=(ax.TightInset(1)-ax.Position(1))/ax.Position(3)*(ax.XLim(2)-ax.XLim(1));
    text(ax,ax.XLim(1)+sepX,(ax.YLim(2)+ax.YLim(1))/2,ax.YLabel.String,...
       'HorizontalAlignment','center','FontWeight','bold','VerticalAlignment','middle',...
       'Color',[0.3,0.3,0.3],'FontName','Comic Sans MS','FontSize',16,'Rotation',90);
end


% 框线图重绘
if ~isempty(ax.UserData)
    for i=1:length(ax.UserData)
        aBox=ax.UserData{i};
        x=aBox.X;
        y=aBox.Y;
        X=(x-ax.Position(1))./ax.Position(3).*(ax.XLim(2)-ax.XLim(1))+ax.XLim(1);
        Y=(y-ax.Position(2))./ax.Position(4).*(ax.YLim(2)-ax.YLim(1))+ax.YLim(1);
        xSet=linspace(X(1),X(2),40);
        ySet=(rand([1,length(xSet)])-0.5).*(ax.YLim(2)-ax.YLim(1)).*0.006;
        nXSet=linspace(X(1),X(2),10);
        nYSet=interp1(xSet,ySet,nXSet,'spline');
        plot(ax,nXSet,linspace(Y(1),Y(2),10)+nYSet,'LineWidth',3,'Color',[1 1 1]);
        plot(ax,nXSet,linspace(Y(1),Y(2),10)+nYSet,'LineWidth',2,'Color',[.2,.2,.2]);
        aBox.Visible='off';
        text(ax,X(1)-0.4*(X(2)-X(1)),Y(1)-0.4*(Y(2)-Y(1)),aBox.String,...
            'HorizontalAlignment','center','FontWeight','bold',...
            'Color',[0.3,0.3,0.3],'FontName','Comic Sans MS','FontSize',13);
    end
end

if textflag
for i=1:length(textSet)
    text(ax,'Position',textSet(i).Position,'String',textSet(i).String,...
        'HorizontalAlignment',textSet(i).HorizontalAlignment,'FontWeight','bold',...
        'Color',[0.3,0.3,0.3],'FontName','Comic Sans MS','FontSize',13);  
    textSet(i).Visible='off';
end
end



% legend 重绘 =============================================================
if ~isempty(ax.Legend)
    lgdPos=ax.Legend.Position;
    xyMin=[(lgdPos(1)-ax.Position(1))/ax.Position(3)*(ax.XLim(2)-ax.XLim(1))+ax.XLim(1),...
        (lgdPos(2)-ax.Position(2))/ax.Position(4)*(ax.YLim(2)-ax.YLim(1))+ax.YLim(1)];
    xyMax=[(lgdPos(1)+lgdPos(3)-ax.Position(1))/ax.Position(3)*(ax.XLim(2)-ax.XLim(1))+ax.XLim(1),...
        (lgdPos(2)+lgdPos(4)-ax.Position(2))/ax.Position(4)*(ax.YLim(2)-ax.YLim(1))+ax.YLim(1)];
    ax.Legend.Title.Visible='off';
    diffX=xyMax(1)-xyMin(1);
    diffY=xyMax(2)-xyMin(2);
    text(ax,xyMin(1),xyMax(2),[' ',ax.Legend.Title.String],...
        'FontSize',15,'VerticalAlignment','top','FontWeight','bold','HorizontalAlignment','left',...
        'FontName','Comic Sans MS','Color',[0.3,0.4,0.2]);
    ax.Legend.Visible='off';
    if isempty(ax.Legend.Title.String)
        flag=0;
    else
        flag=1;
    end
    for i=1:length(lineSet)
        xSet=linspace(ax.XLim(1),ax.XLim(2),40);
        ySet=(rand([1,length(xSet)])-0.5).*(ax.YLim(2)-ax.YLim(1)).*0.006;
        
        baseLenX=diffY.*(1)/(length(lineSet)+2);
        
        nXSet=linspace(min(xyMin(1)+0.1*diffX,xyMin(1)+0.3*baseLenX),min(xyMin(1)+0.4*diffX,xyMin(1)+2*baseLenX),50);
        nYSet=interp1(xSet,ySet,nXSet,'spline');
        plot(ax,nXSet,(xyMin(2)+diffY.*(length(lineSet)+1-i-0.5)/(length(lineSet)+flag*1.5)).*ones(1,50)+nYSet,...
            'LineWidth',lineSet(i).LineWidth,'Color',lineSet(i).Color);
        text(ax,min(xyMin(1)+0.52*diffX,xyMin(1)+2.3*baseLenX),(xyMin(2)+diffY.*(length(lineSet)+1-i-0.5)/(length(lineSet)+flag*1.5)),ax.Legend.String{i},...
            'FontSize',13,'FontWeight','bold','HorizontalAlignment','left',...
            'FontName','Comic Sans MS','Color',[0.3,0.4,0.2]);
    end
end
end
