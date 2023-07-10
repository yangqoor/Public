% line area
% @author : slandarer
% @公众号 : slandarer随笔

clc;clear


% 导入数据，更多的数据也请使用
% Data(n).X=......的格式
Data(1).X=mvnrnd(40,60,300);
Data(2).X=mvnrnd(60,60,600);
Data(3).X=mvnrnd(80,60,900);
Data(4).X=mvnrnd(100,60,1200);
Data(5).X=mvnrnd(120,60,1200);

% 一些基础设置
scatterSep='off'; % 是否分开绘制竖线散点
totalRatio='on';  % 是否各组按比例绘制

% 配色列表
C1=[211 43 43;61 96 137;249 206 61;76 103 86;80 80 80]./255;
C2=[102,173,194;36,59,66;232,69,69;194,148,102;54,43,33]./255;
C3=[244,241,222;223,122,94;60 64 91;130 178 154;240 201 134]./255;
C4=[126,15,4;122,117,119;255,163,25;135,146,73;30,93,134]./255;
C5=[198,199,201;38,74,96;209,80,51;241,174,44;12,13,15]./255;
C6=[235,75,55;77,186,216;2,162,136;58,84,141;245,155,122]./255;
C7=[23,23,23;121,17,36;44,9,75;31,80,91;61,36,42]./255;
C8=[47,62,66;203,129,70;0 64 115;152,58,58;20 72 83]./255;
colorList=C2;



% =========================================================================
 
% 图像绘制
ax=gca;hold on
N=length(Data);
areaHdl(N)=nan;
lgdStrs{N}='';

% 计算各类数据量
K=arrayfun(@(x) length(x.X),Data);
% 循环绘图
for n=1:N
    [f,xi]=ksdensity(Data(n).X);
    if strcmp(totalRatio,'on')
        f=f.*K(n)./sum(K);
    end
    areaHdl(n)=area(xi,f,'FaceColor',colorList(n,:),...
        'EdgeColor',colorList(n,:),'FaceAlpha',.5,'LineWidth',1.5);
    lgdStrs{n}=['Group ',num2str(n)];
end


% 绘制图例
lgd=legend(areaHdl,lgdStrs{:});
lgd.AutoUpdate='off';
lgd.Location='best';

% 调整轴范围
posSep=ax.YLim(2)-0;
if strcmp(scatterSep,'on')
    ax.YLim(1)=-posSep/6*N;
else
    ax.YLim(1)=-posSep/6;
end
ax.XLim=ax.XLim;
totalSep=diff(ax.YLim);

for n=1:N
    dy=strcmp(scatterSep,'on');
    LY=ones(1,K(n)).*[(-posSep/6).*(.1+dy.*(n-1));(-posSep/6.)*(.9+dy.*(n-1));nan];
    LX=[Data(n).X(:)';Data(n).X(:)';ones(1,K(n)).*nan];
    line(LX(:),LY(:),'Color',[colorList(n,:),.4],'lineWidth',1)
end

% 坐标区域修饰
ax.Box='on';
ax.BoxStyle='full';
ax.LineWidth=1;
ax.FontSize=11;
ax.FontName='Arial';
ax.TickDir='out';
ax.TickLength=[.005,.1];
ax.YTick(ax.YTick<-eps)=[];
ax.Title.String='area plot with | scatter';
ax.Title.FontSize=14;
ax.XLabel.String='XXXXX';
ax.YLabel.String='YYYYY';

% 绘制基准线及框线
fplot(@(t)t.*0,'Color',ax.XColor,'LineWidth',ax.LineWidth);

