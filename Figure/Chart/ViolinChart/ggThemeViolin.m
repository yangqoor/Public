function ax=ggThemeViolin(varargin)
% @author:slandarer
% 
% 参数说明：
% -----------------------------------------------------
% AxesTheme   | 坐标区域风格       | 'flat'/'flat_dark'/'camouflage'/'chalk'/
%                                    'copper'/'dust'/'earth'/'fresh'/'grape'/
%                                    'grass'/'greyscale'/'light'/'lilac'/'pale'
%                                    'sea'/'sky'/'solarized'
%
% HDLset      | 句柄集合    

% 获取要处理的坐标区域=====================================================
if strcmp(get(varargin{1},'type'),'axes' )
    ax=varargin{1};
else
    ax=gca;
end
hold(ax,'on')

% 获取要处理的图像句柄=====================================================
HDLset=varargin{2};

% 获取风格名称=============================================================
theme.AxesTheme='flat';
if length(varargin)>2
    theme.AxesTheme=varargin{3};
end



% 开始风格化===============================================================
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

for i=1:length(HDLset)
    for j=1:length(HDLset(i).F_density)
        HDLset(i).F_density(j).FaceColor=ax.ColorOrder(mod(i-1,size(ax.ColorOrder,1))+1,:);
        HDLset(i).F_density(j).EdgeColor=[.1,.1,.1];
        
        f_max=(max(HDLset(i).F_density(j).XData)-min(HDLset(i).F_density(j).XData))/2;
        x_mid=(max(HDLset(i).F_density(j).XData)+min(HDLset(i).F_density(j).XData))/2;
        

        HDLset(i).F_quantile(j).XData=x_mid+0.4.*f_max.*[-1 1 1 -1];
        HDLset(i).F_quantile(j).FaceColor=[1 1 1].*0.95;
        
        HDLset(i).F_medianLine(j).XData=x_mid+0.4.*f_max.*[-1 1];
        HDLset(i).F_medianLine(j).LineWidth=2;
        HDLset(i).F_medianLine(j).Color=[0.3,0.3,0.3];
        
        
        if nargin>=3
            if ~isempty(intersect(varargin(3:end),'LP'))
                HDLset(i).F_medianLine(j).XData=x_mid;
                HDLset(i).F_medianLine(j).YData=HDLset(i).F_medianLine(j).YData(1);
                HDLset(i).F_medianLine(j).Marker='o';
                HDLset(i).F_medianLine(j).MarkerSize=4;
                HDLset(i).F_medianLine(j).MarkerEdgeColor=[1 1 1].*.98;
                HDLset(i).F_medianLine(j).MarkerFaceColor=[1 1 1].*.98;
                HDLset(i).F_medianLine(j).LineWidth=0.5;
                HDLset(i).F_quantile(j).XData=x_mid+0.15.*f_max.*[-1 1 1 -1];
                HDLset(i).F_quantile(j).FaceColor=[1 1 1].*0.3;
                
            end
        end
        
        HDLset(i).F_outlier(j).CData=Tm.(theme.AxesTheme).EdgeColor;
    end
    
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
    ax.Legend.AutoUpdate='off';
end

end