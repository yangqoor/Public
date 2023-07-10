function scratchCard
strSet={'520元红包一个',15/100;
        '1314元红包一个',5/100;
        '黑丝水手服',20/100;
        '黑丝女仆装',20/100;
        '抱抱×50次',20/100;
        '亲亲×50次',20/100;}; 
probVal=cell2mat(strSet(:,2));
% 将概率密度函数转换为概率分布函数
for i=2:length(probVal)
    probVal(i)=probVal(i)+probVal(i-1);
end


fig=figure('units','pixels');
fig.Position=[300 80 600 200];
fig.NumberTitle='off';
fig.MenuBar='none';
fig.Resize='off';
fig.Name='刮刮乐';

ax=axes(fig);
ax.Position=[0 0 1 1];
ax.XTick=[];
ax.YTick=[];
ax.ZTick=[];
ax.XLim=[0 600];
ax.YLim=[0 200];
hold(ax,'on')


randNum=rand();
numRange=probVal>randNum;
strPos=find(numRange,1);
text(300,100,strSet{strPos,1},...
    'HorizontalAlignment','center','FontSize',60)

coverageMat_C=ones(200,600,3).*0.62;
coverageMat_A=ones(200,600);
[xMesh,yMesh]=meshgrid(1:600,1:200);

coverageHdl=image([0 600],[0 200],coverageMat_C,...
                  'AlphaData',coverageMat_A);

isClicking=false;
set(fig,'WindowButtonDownFcn',@bt_down);
function bt_down(~,~),isClicking=true;end

set(fig,'WindowButtonUpFcn',@bt_up);
function bt_up(~,~),isClicking=false;end
             
set(fig,'WindowButtonMotionFcn',@bt_move);
function bt_move(~,~)
    if isClicking
        mousePos=fig.CurrentPoint;
        boolPos=sqrt((xMesh-mousePos(1)).^2+(yMesh-mousePos(2)).^2)<=15;
        coverageMat_A(boolPos)=0;
        set(coverageHdl,'AlphaData',coverageMat_A)
    end
end


end
