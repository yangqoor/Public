function ax=ggThemeBox(varargin)
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
ax.LineWidth=1.3;
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

n=1;
for i=length(ax.Children):-1:1
    ax.Children(i).Visible='on';
    ax.Children(i).WhiskerLineColor='none';
    ax.Children(i).BoxFaceColor=ax.ColorOrder(mod(n-1,size(ax.ColorOrder,1))+1,:);
    ax.Children(i).BoxFaceAlpha=1;
    axBp(i)=ax.Children(i);
    n=n+1;
end


Bw=axBp(1).BoxWidth;
Sw=1-Bw;
if length(axBp(1).XData(:))~=length(axBp(1).YData(:))
    n=1;
    for i=length(axBp):-1:1
        tDataX=axBp(i).XData;
        tDataY=axBp(i).YData;
        for j=1:length(axBp(i).XData)
            tjDataX=double(tDataX(j));
            fullDataY=tDataY(:,j);
            tjDataY=tDataY(:,j);
            if ~isempty(tjDataY)
                outliBool=isoutlier(tjDataY,'quartiles');
                outli=tjDataY(outliBool);
                scatter(repmat(tjDataX,[sum(outliBool),1]),outli,45,'filled',...
                    'CData',Tm.(theme.AxesTheme).EdgeColor,'MarkerEdgeColor','none')
                
                tjDataY(outliBool)=[];
                plot([tjDataX,tjDataX],[max(tjDataY),min(tjDataY)],'LineWidth',1.2,...
                    'Color',Tm.(theme.AxesTheme).EdgeColor)
                
                qt25=quantile(fullDataY,0.25);
                qt75=quantile(fullDataY,0.75);
                fill(tjDataX+Bw.*0.5.*[-1 1 1 -1],...
                    [qt25,qt25,qt75,qt75],ax.ColorOrder(mod(n-1,size(ax.ColorOrder,1))+1,:),...
                    'EdgeColor',Tm.(theme.AxesTheme).EdgeColor);
                
                med=median(fullDataY);
                plot([tjDataX-Bw.*0.5,tjDataX+Bw.*0.5],[med,med],'LineWidth',3,...
                    'Color',Tm.(theme.AxesTheme).EdgeColor)
            end
        end
        n=n+1;
    end
else
    n=1;
    nBw=Bw/length(axBp)/2;
    nSw=Sw/length(axBp)/2;
    for i=length(axBp):-1:1
        tDataX=axBp(i).XData;
        tDataY=axBp(i).YData;
        cgX=categories(tDataX);
        for j=1:length(cgX)
            fullDataY=tDataY(tDataX==cgX{j});
            tjDataY=tDataY(tDataX==cgX{j});
            if ~isempty(tjDataY)
                outliBool=isoutlier(tjDataY,'quartiles');
                outli=tjDataY(outliBool);
                tjDataX=j-(length(axBp)-1)*(nSw+nSw)+(length(axBp)-i)*2*(nSw+nSw);
                scatter(repmat(tjDataX,[length(outli),1]),outli,'filled',...
                    'CData',Tm.(theme.AxesTheme).EdgeColor,'MarkerEdgeColor','none')
                
                tjDataY(outliBool)=[];
                plot([tjDataX,tjDataX],[max(tjDataY),min(tjDataY)],'LineWidth',1.2,...
                    'Color',Tm.(theme.AxesTheme).EdgeColor)
                
                qt25=quantile(fullDataY,0.25);
                qt75=quantile(fullDataY,0.75);
                fill(tjDataX+nBw.*[-1 1 1 -1],...
                    [qt25,qt25,qt75,qt75],ax.ColorOrder(mod(n-1,size(ax.ColorOrder,1))+1,:),...
                    'EdgeColor',Tm.(theme.AxesTheme).EdgeColor)
                
                med=median(fullDataY);
                plot([tjDataX-nBw,tjDataX+nBw],[med,med],'LineWidth',3,...
                    'Color',Tm.(theme.AxesTheme).EdgeColor)
            end
        end
        n=n+1;
    end
end
end