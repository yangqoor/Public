function maze
fg=gcf;
fg.MenuBar='none';
ax=axes(fg);
ax.XLim=[0.5 30.5];
ax.YLim=[0.5 20];
ax.Position=[0 0 1 1];
ax.YDir='reverse';
ax.Toolbar.Visible='off';
ax.DataAspectRatio=[1 1 1];
ax.XColor=[.98 .98 .98];
ax.YColor=[.98 .98 .98];
hold(ax,'on')
Map=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;
     5 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 1 0 1 0 1 0 0 0 0 0 0 0 1;
     1 1 1 1 0 1 0 1 0 1 1 1 0 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 0 1;
     1 0 0 1 0 0 0 1 0 0 0 1 0 0 0 0 0 1 1 1 0 1 0 0 0 0 0 1 0 1;
     1 1 0 1 1 1 1 1 0 1 1 1 0 1 0 1 0 0 1 1 1 1 0 1 1 1 1 1 0 1;
     1 0 0 0 0 0 0 0 0 0 0 1 0 1 0 1 1 0 1 0 1 0 0 0 0 1 0 0 0 1;
     1 1 0 1 1 1 1 1 1 1 0 1 0 1 1 1 0 0 0 0 1 1 1 1 0 1 0 1 1 1;
     1 1 0 0 0 0 0 1 0 1 0 1 0 1 0 1 1 0 1 1 1 0 0 0 0 1 0 0 0 1;
     1 1 1 1 0 1 1 1 0 1 0 1 0 0 0 1 0 0 1 0 0 0 1 1 0 1 1 1 0 1;
     1 0 0 0 0 1 0 0 0 0 0 1 1 1 1 1 1 1 1 0 1 1 1 1 0 1 0 0 0 1;
     1 0 1 1 1 1 1 1 1 1 1 1 0 0 1 0 0 0 0 0 0 1 0 1 1 1 0 1 1 1;
     1 0 0 1 0 0 0 1 0 0 0 0 0 1 1 1 0 1 1 0 1 1 0 1 0 0 0 0 0 1;
     1 1 0 0 0 1 0 0 0 1 0 1 0 1 0 0 0 0 0 0 0 1 0 1 0 1 0 1 0 1;
     1 0 0 1 1 1 1 0 1 1 0 1 0 1 1 1 1 1 0 1 1 1 0 1 1 1 1 1 1 1;
     1 1 1 1 0 0 0 0 1 0 0 1 0 1 0 1 1 1 0 0 0 1 0 0 0 0 0 0 0 1;
     1 1 0 1 1 1 1 1 1 1 1 1 0 1 0 0 0 1 1 1 0 1 1 1 0 1 1 1 0 1;
     1 1 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 1 0 0 0 0 0 0 0 1 0 0 0 1;
     1 0 0 1 1 1 0 1 1 1 0 1 1 1 0 1 0 1 1 1 1 0 1 1 0 1 0 1 1 1;
     1 1 0 0 0 1 0 0 0 1 0 0 0 0 0 1 0 1 1 0 0 0 1 0 0 1 0 0 0 4;
     1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
mazeImage=imagesc(Map);
[startPnt.x,startPnt.y]=find(Map==5);
[endPnt.x,endPnt.y]=find(Map==4);
Dir=[1 0;0 -1;-1 0;0 1];
Path=[startPnt.x,startPnt.y];
breakflag=1;
while(breakflag)
    tailPnt=Path(end,:);
    flag=0;
    for i=1:4
        if (tailPnt(1)+Dir(i,1)>=1&&tailPnt(1)+Dir(i,1)<=20&&...
            tailPnt(2)+Dir(i,2)>=1&&tailPnt(2)+Dir(i,2)<=30)&&...     
           (Map(tailPnt(1)+Dir(i,1),tailPnt(2)+Dir(i,2))==0||...
            Map(tailPnt(1)+Dir(i,1),tailPnt(2)+Dir(i,2))==4)
            flag=i;break;   
        end     
    end
    if flag==0
        Map(tailPnt(1),tailPnt(2))=3;
        Path(end,:)=[]; 
    else
        if Map(tailPnt(1)+Dir(flag,1),tailPnt(2)+Dir(flag,2))==4
            breakflag=0;
        else
            Map(tailPnt(1)+Dir(flag,1),tailPnt(2)+Dir(flag,2))=2;
            Path=[Path;tailPnt(1)+Dir(flag,1),tailPnt(2)+Dir(flag,2)];
        end
    end
    pause(0.02)
    delete(mazeImage);
    mazeImage=imagesc(Map);
end



end
