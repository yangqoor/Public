function getPointer
fg=figure;
fg.NumberTitle='off';
fg.MenuBar='none';
fg.Resize='off';
fg.Position=[100 100 500 500];
fg.Name='getPointer';

ax=axes(fg);
ax.Position=[0 0 1 1];
ax.XLim=[-1 101];
ax.YLim=[-1 101];
ax.Color=[0 0 0];
hold(ax,'on');
[xSet,ySet]=meshgrid(0:100,0:100);
xSet=xSet(:);ySet=ySet(:);
oriX=xSet;oriY=ySet;
sc=scatter(xSet,ySet,1,'filled','CData',[1 1 1]);


set(gcf,'WindowButtonMotionFcn',@whilemovefcn)  
    function whilemovefcn(~,~)
        xy=get(gca,'CurrentPoint');
        x=xy(1,1);y=xy(1,2);
        nearPos=sqrt((xSet-x).^2+(ySet-y).^2)<5;
        xySet=[xSet,ySet];
        dir=[xSet,ySet]-[x,y];
        len=sqrt((xSet-x).^2+(ySet-y).^2);
        moveDis=5.8./(len+1);
        newPos=dir.*moveDis+[x,y];
        xySet(nearPos,:)=newPos(nearPos,:);
        set(sc,'XData',xySet(:,1),'YData',xySet(:,2))
        xSet=xySet(:,1);ySet=xySet(:,2);
    end

fps=50;
gptimer=timer('ExecutionMode', 'fixedRate', 'Period',1/fps, 'TimerFcn', @gp);
start(gptimer)

    function gp(~,~)     
        dirX=oriX-xSet;
        dirY=oriY-ySet;
        xSet=xSet+dirX.*(1/15);
        ySet=ySet+dirY.*(1/15);
        set(sc,'XData',xSet,'YData',ySet)
    end
end
