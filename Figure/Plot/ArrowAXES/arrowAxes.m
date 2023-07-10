function arrowAxes(ax)
%
% @author: slandarer
% @公众号: slandarer随笔
% @知乎  : hikari
% @CSDN  : slandarer
% 
% 期待您的关注!!!

help arrowAxes % 若不希望输出[作者信息],请删除这行


if nargin<1
    ax=gca;
end

ax.Box='off';
ax.UserData.arrow{1}=[];
ax.UserData.arrow{2}=[];
ax.UserData.arrow{3}=[];
ax.UserData.arrow{4}=[];

pos=ax.Position;
xm=.02;
ym=.02;
% -------------------------------------------------------------------------
switch ax.XAxisLocation
    case 'bottom'
        ax.UserData.arrow{2}=annotation('arrow');
        ax.UserData.arrow{2}.Color=ax.YColor;
        ax.UserData.arrow{2}.Position=[pos(1),pos(2),0,pos(4)+ym];
    case 'top'
        ax.UserData.arrow{4}=annotation('arrow');
        ax.UserData.arrow{4}.Color=ax.YColor;
        ax.UserData.arrow{4}.Position=[pos(1),pos(2)+pos(4),0,-pos(4)-ym];
    case 'origin'
        ax.UserData.arrow{2}=annotation('arrow');
        ax.UserData.arrow{2}.Color=ax.YColor;
        ax.UserData.arrow{2}.Position=[pos(1),pos(2),0,pos(4)+ym];
        ax.UserData.arrow{4}=annotation('arrow');
        ax.UserData.arrow{4}.Color=ax.YColor;
        ax.UserData.arrow{4}.Position=[pos(1),pos(2)+pos(4),0,-pos(4)-ym];
end
switch ax.YAxisLocation
    case 'left'
        ax.UserData.arrow{1}=annotation('arrow');
        ax.UserData.arrow{1}.Color=ax.XColor;
        ax.UserData.arrow{1}.Position=[pos(1),pos(2),pos(3)+xm,0];
    case 'right'
        ax.UserData.arrow{3}=annotation('arrow');
        ax.UserData.arrow{3}.Color=ax.XColor;
        ax.UserData.arrow{3}.Position=[pos(1)+pos(3),pos(2),-pos(3)-xm,0];
    case 'origin'
        ax.UserData.arrow{1}=annotation('arrow');
        ax.UserData.arrow{1}.Color=ax.XColor;
        ax.UserData.arrow{1}.Position=[pos(1),pos(2),pos(3)+xm,0];
        ax.UserData.arrow{3}=annotation('arrow');
        ax.UserData.arrow{3}.Color=ax.XColor;
        ax.UserData.arrow{3}.Position=[pos(1)+pos(3),pos(2),-pos(3)-xm,0];
end

if strcmp(ax.XAxisLocation,'top')
    if ~isempty(ax.UserData.arrow{1}),ax.UserData.arrow{1}.Position=[pos(1),pos(2)+pos(4),pos(3)+xm,0];end
    if ~isempty(ax.UserData.arrow{3}),ax.UserData.arrow{3}.Position=[pos(1)+pos(3),pos(2)+pos(4),-pos(3)-xm,0];end
end
if strcmp(ax.YAxisLocation,'right')
    if ~isempty(ax.UserData.arrow{2}),ax.UserData.arrow{2}.Position=[pos(1)+pos(3),pos(2),0,pos(4)+ym];end
    if ~isempty(ax.UserData.arrow{4}),ax.UserData.arrow{4}.Position=[pos(1)+pos(3),pos(2)+pos(4),0,-pos(4)-ym];end
end
for i=1:4
    if ~isempty(ax.UserData.arrow{i}),ax.UserData.arrow{i}.LineWidth=ax.LineWidth;end
end


reArrow()
% -------------------------------------------------------------------------
function reArrow(~,~)
if strcmp(ax.XAxisLocation,'origin')
    pos=ax.Position;
    ylim=ax.YLim;
    sepy=(0-ylim(1))./(ylim(2)-ylim(1)).*pos(4);
    switch true
        case ylim(2)<=0
            if ~isempty(ax.UserData.arrow{1}),ax.UserData.arrow{1}.Position=[pos(1),pos(2)+pos(4),pos(3)+xm,0];end
            if ~isempty(ax.UserData.arrow{3}),ax.UserData.arrow{3}.Position=[pos(1)+pos(3),pos(2)+pos(4),-pos(3)-xm,0];end
        case ylim(1)>=0
            if ~isempty(ax.UserData.arrow{1}),ax.UserData.arrow{1}.Position=[pos(1),pos(2),pos(3)+xm,0];end
            if ~isempty(ax.UserData.arrow{3}),ax.UserData.arrow{3}.Position=[pos(1)+pos(3),pos(2),-pos(3)-xm,0];end
        case ylim(2)>0&ylim(1)<0
            if ~isempty(ax.UserData.arrow{1}),ax.UserData.arrow{1}.Position=[pos(1),pos(2)+sepy,pos(3)+xm,0];end
            if ~isempty(ax.UserData.arrow{3}),ax.UserData.arrow{3}.Position=[pos(1)+pos(3),pos(2)+sepy,-pos(3)-xm,0];end
    end
end
if strcmp(ax.YAxisLocation,'origin')
    pos=ax.Position;
    xlim=ax.XLim;
    sepx=(0-xlim(1))./(xlim(2)-xlim(1)).*pos(3);
    switch true
        case xlim(2)<=0
            if ~isempty(ax.UserData.arrow{2}),ax.UserData.arrow{2}.Position=[pos(1)+pos(3),pos(2),0,pos(4)+ym];end
            if ~isempty(ax.UserData.arrow{4}),ax.UserData.arrow{4}.Position=[pos(1)+pos(3),pos(2)+pos(4),0,-pos(4)-ym];end
        case xlim(1)>=0
            if ~isempty(ax.UserData.arrow{2}),ax.UserData.arrow{2}.Position=[pos(1),pos(2),0,pos(4)+ym];end
            if ~isempty(ax.UserData.arrow{4}),ax.UserData.arrow{4}.Position=[pos(1),pos(2)+pos(4),0,-pos(4)-ym];end
        case xlim(2)>0&xlim(1)<0
            if ~isempty(ax.UserData.arrow{2}),ax.UserData.arrow{2}.Position=[pos(1)+sepx,pos(2),0,pos(4)+ym];end
            if ~isempty(ax.UserData.arrow{4}),ax.UserData.arrow{4}.Position=[pos(1)+sepx,pos(2)+pos(4),0,-pos(4)-ym];end
    end
end
end
set(ax.Parent,'WindowButtonMotionFcn',@reArrow);  % 设置鼠标按下回调
end