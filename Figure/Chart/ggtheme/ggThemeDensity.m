function ax=ggThemeDensity(varargin)
% @author:slandarer
% 
% 参数说明：
% -----------------------------------------------------
% AxesTheme   | 坐标区域风格       | 'flat'/'flat_dark'/'camouflage'/'chalk'/
%                                    'copper'/'dust'/'earth'/'fresh'/'grape'/
%                                    'grass'/'greyscale'/'light'/'lilac'/'pale'
%                                    'sea'/'sky'/'solarized'

% 获取要处理的坐标区域=====================================================
if strcmp(get(varargin{1},'type'),'axes' )
    ax=varargin{1};
else
    ax=gca;
end
hold(ax,'on')


% default==================================================================
theme.AxesTheme='flat';
if length(varargin)>1
    theme.AxesTheme=varargin{2};
end

ax.Box='off';
ax.YGrid='on';
ax.XGrid='on';
ax.GridLineStyle='--';
ax.LineWidth=1.2;

% 主题风格化
Tm=load('themeCSS.mat');
Tm=Tm.theme;
ax.Color=Tm.(theme.AxesTheme).Color;
ax.TickLength=Tm.(theme.AxesTheme).TickLength;
ax.GridColorMode=Tm.(theme.AxesTheme).GridColorMode;
ax.GridColor=Tm.(theme.AxesTheme).GridColor;
ax.GridAlpha=Tm.(theme.AxesTheme).GridAlpha;
ax.XColor=Tm.(theme.AxesTheme).XColor;
ax.YColor=Tm.(theme.AxesTheme).YColor;
ax.TickDir=Tm.(theme.AxesTheme).TickDir;
ax.ColorOrder=Tm.(theme.AxesTheme).ColorOrder;
ax.XLim=ax.XLim;
ax.YLim=ax.YLim;

if ~isempty(ax.Legend)
    tStr=ax.Legend.String;
end


for i=length(ax.Children):-1:1
    axDS(i)=ax.Children(i);
end
n=1;
for i=length(axDS):-1:1
    if strcmp(get(axDS(i),'type'),'line')
        tXData=axDS(i).XData;
        tYData=axDS(i).YData;
        if tXData(1)>tXData(end)
            tXData=tXData(end:-1:1);
            tYData=tYData(end:-1:1);
        end
        tXData=[min(tXData),tXData,max(tXData)];
        tYData=[0,tYData,0];
        fill(ax,tXData,tYData,ax.ColorOrder(mod(n-1,size(ax.ColorOrder,1))+1,:),...
            'LineWidth',1.4,'EdgeColor',ax.ColorOrder(mod(n-1,size(ax.ColorOrder,1))+1,:),...
            'FaceAlpha',0.7);
        n=n+1;
    end
end
for i=length(axDS):-1:1
    delete(axDS(i));
end

if ~isempty(ax.Legend)
    ax.Legend.Box='off';
    ax.Legend.FontSize=12;
    if mean(ax.Color)>0.6
        ax.Legend.TextColor=ax.XColor;
    else
        ax.Legend.TextColor=[0.9 0.9 0.9];
    end
    if ~isempty(regexpi(ax.Legend.Location,'out', 'once'))
        ax.Legend.TextColor=ax.XColor;
        ax.Legend.Title.FontSize=14;
    end
    ax.Legend.String=tStr;
end

end