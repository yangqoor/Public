function scratchCard
strSet={'520Ԫ���һ��',15/100;
        '1314Ԫ���һ��',5/100;
        '��˿ˮ�ַ�',20/100;
        '��˿Ů��װ',20/100;
        '������50��',20/100;
        '���ס�50��',20/100;}; 
probVal=cell2mat(strSet(:,2));
% �������ܶȺ���ת��Ϊ���ʷֲ�����
for i=2:length(probVal)
    probVal(i)=probVal(i)+probVal(i-1);
end


fig=figure('units','pixels');
fig.Position=[300 80 600 200];
fig.NumberTitle='off';
fig.MenuBar='none';
fig.Resize='off';
fig.Name='�ι���';

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
