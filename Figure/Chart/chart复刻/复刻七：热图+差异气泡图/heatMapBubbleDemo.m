%% ========================================================================
% 数据导入
% 若下载了test.csv数据则可如下方式读取
DataTable=readtable('test.csv');

rowName=DataTable.gene;
colName=DataTable.Properties.VariableNames(2:end);

DataTable(:,1)=[];
Data=DataTable.Variables;
Data=Data(:,1:6);

pValue=DataTable.pvalue;
log2fc=DataTable.log2fc;
negLog10pValue=-log(pValue)./log(10);

% 若未下载则直接如下方式输入数据
% Data=[1.5864    0.6541    0.2134   -0.8593   -0.8017   -0.7929
%     0.3845    1.0750    1.1756       NaN       NaN       NaN
%     1.1575    0.1645    1.2177       NaN       NaN       NaN
%     1.3135    0.7609    0.5834   -0.8976   -0.8639   -0.8963
%     0.0842    1.7035    0.5355   -0.8321   -0.7396   -0.7514
%     1.2165    0.4733    0.9692   -0.8847       NaN   -0.8803
%     0.4412    1.2686    0.9186   -0.9177   -0.7025   -1.0082
%     0.6485    1.2007    0.8095   -1.0422   -0.5964   -1.0201
%     0.1135    0.9586    1.4159       NaN       NaN       NaN
%     1.1576   -1.0688    0.1170   -1.2459    0.9733    0.0668
%     0.6961    1.1603    0.6978   -1.4045   -0.7309   -0.4188
%     1.1161    0.9638    0.6186   -0.9938   -0.8178   -0.8869
%     0.9603    0.8072    0.7459   -1.4862   -0.2553   -0.7719
%    -0.8845    1.8258   -0.1787    0.3954   -0.6913   -0.4667
%     1.3863    0.7003    0.5386   -0.8950   -0.8591   -0.8710
%     0.2966    0.3935    1.6926   -0.7993   -0.8023   -0.7809
%     1.1849    1.1460    0.2237   -0.9502   -0.6559   -0.9484];
% colName={'KC_1','KC_2','KC_3','Liver_rec_1','Liver_rec_2','Liver_rec_3'};
% rowName={'Hmox1','Hrg','Tfr2','Tfrc','Trf','Atp13a2','Atp6ap1','Hpx','Slc11a1','Slc11a2','Slc40a1','Lrp1','Hmox2','Fth1','Cd163','Abcb6','Hscb'};
% pValue=[0.0558,0.0195,0.0384,0.0149,0.0843,0.0148,0.0104,0.0013,0.0490,0.8875,0.0135,0.0032,0.0389,0.6076,0.0212,0.0717,0.0241];
% log2fc=[1.3481,4.4350,4.9859,1.6607,1.0708,2.3686,0.9994,0.8831,4.6713,0.0449,0.5541,0.8657,0.3719,0.1013,1.3980,1.1047,0.8352];
% negLog10pValue=-log(pValue)./log(10);


% =========================================================================
% 配色

% 不同类型颜色
type=[1,1,1,2,2,2];
typeColor=[105,143,45;157,191,61]./255;

% 以下是colormap配色
% 若下载了slanCM配色工具包
% 该工具函数使用详见：https://mp.weixin.qq.com/s/6Fr2pYMrA5_EStF9UudvsQ
% 引用：Zhaoxu Liu / slandarer (2023). 200 colormap 
% (https://www.mathworks.com/matlabcentral/fileexchange/120088-200-colormap), 
% MATLAB Central File Exchange. 检索来源 2023/2/6.
CM1=slanCM(98);
CM1=flipud(CM1(37:220,:));
CM2=slanCM(12);
CM2=CM2(30:200,:);

% 若没下载slanCM配色工具包
% CM1=[0.6471         0    0.1490
%     0.7503    0.0991    0.1511
%     0.8491    0.2008    0.1587
%     0.9090    0.3267    0.2165
%     0.9606    0.4543    0.2751
%     0.9792    0.5884    0.3370
%     0.9928    0.7133    0.4095
%     0.9948    0.8165    0.5065
%     0.9969    0.9040    0.6035
%     0.9990    0.9680    0.7005
%     0.9680    0.9876    0.8078
%     0.9040    0.9628    0.9255
%     0.8128    0.9207    0.9540
%     0.7034    0.8671    0.9230
%     0.5911    0.7874    0.8791
%     0.4776    0.6966    0.8295
%     0.3773    0.5860    0.7717
%     0.2803    0.4704    0.7119
%     0.2334    0.3418    0.6483
%     0.1922    0.2118    0.5843];
% CM2=[1.0000    0.9608    0.9412
%     0.9983    0.9261    0.8916
%     0.9967    0.8914    0.8421
%     0.9940    0.8402    0.7730
%     0.9907    0.7792    0.6921
%     0.9882    0.7164    0.6120
%     0.9882    0.6487    0.5344
%     0.9882    0.5810    0.4568
%     0.9868    0.5148    0.3893
%     0.9851    0.4487    0.3232
%     0.9744    0.3769    0.2654
%     0.9546    0.2993    0.2159
%     0.9298    0.2241    0.1695
%     0.8704    0.1664    0.1447
%     0.8109    0.1086    0.1199
%     0.7490    0.0830    0.1038
%     0.6863    0.0681    0.0906
%     0.6087    0.0495    0.0774
%     0.5063    0.0248    0.0642
%     0.4039         0    0.0510];
% CMX1=linspace(0,1,size(CM1,1))';
% CMX2=linspace(0,1,size(CM2,1))';
% CMXX256=linspace(0,1,256)';
% CM1=[interp1(CMX1,CM1(:,1),CMXX256,'pchip'),interp1(CMX1,CM1(:,2),CMXX256,'pchip'),interp1(CMX1,CM1(:,3),CMXX256,'pchip')];
% CM2=[interp1(CMX2,CM2(:,1),CMXX256,'pchip'),interp1(CMX2,CM2(:,2),CMXX256,'pchip'),interp1(CMX2,CM2(:,3),CMXX256,'pchip')];
%
% CM1=flipud(CM1(37:220,:));
% CM2=CM2(30:200,:);

% =========================================================================
% 使用其他配色
% CM1=slanCM(141);
% CM1=CM1(60:200,:);
% CM2=slanCM(19);
% typeColor=[114,146,184;180,197,215]./255;

% =========================================================================
% figure窗口及axes坐标区域创建
fig=figure('Units','normalized','Position',[.3,.2,.39,.63],'Color',[1,1,1]);
ax1=axes(fig);hold on
ax1.Position=[.02,.1,.37,.88];
ax1.XLim=[0,size(Data,2)]+.5;
ax1.YLim=[-1.25,size(Data,1)]+.5;
ax1.XTick=[];
ax1.YDir='reverse';
ax1.YTick=1:size(Data,1);
ax1.YTickLabel=rowName;
ax1.YAxisLocation='right';
ax1.FontName='Cambria';
ax1.FontSize=13;
ax1.Box='on';
ax1.LineWidth=.01;

ax2=axes(fig);hold on
ax2.Position=[.55,.1,.2,.88./(size(Data,1)+1.25).*size(Data,1)];
ax2.YLim=[0,size(Data,1)]+.5;
ax2.XLim=[-1,1];
ax2.XTick=0;
ax2.XTickLabel='';
ax2.Box='off';
ax2.LineWidth=2;
ax2.TickDir='out';
ax2.YDir='reverse';
ax2.YTick=1:size(Data,1);
ax2.YTickLabel='';
ax2.XGrid='on';
ax2.YGrid='on';
ax2.FontName='Cambria';
ax2.FontSize=13;
fill(ax2,ax2.XLim([1,1,2,2]),ax2.YLim([1,2,2,1]),'w','LineWidth',2,'FaceColor','none')

%% ========================================================================
% 热图绘制
% 由于HeatmapChart 不能是 Axes 的子级, 直接硬画
CLim1=[min(min(Data)),max(max(Data))];
% 生成颜色映射函数
CMX1=linspace(CLim1(1),CLim1(2),size(CM1,1))';
colorFunc1=@(X)[interp1(CMX1,CM1(:,1),X,'pchip'),interp1(CMX1,CM1(:,2),X,'pchip'),interp1(CMX1,CM1(:,3),X,'pchip')];
% 循环绘制分类
fill(ax1,[0,0,size(Data,2),size(Data,2)]+.5,[.5,0,0,.5],[1,1,1],'EdgeColor',[1,1,1])
for j=1:size(Data,2)
     fill(ax1,j+[-.5,-.5,.5,.5],-.5+[-.5,.5,.5,-.5],typeColor(type(j),:),'EdgeColor','none')
end
% 循环绘制热图，nan处绘制x号
for i=1:size(Data,1)
    for j=1:size(Data,2)
        if ~isnan(Data(i,j))
            tColor=colorFunc1(Data(i,j));
        else
            tColor=[205,205,205]./255;
        end
        fill(ax1,j+[-.5,-.5,.5,.5],i+[-.5,.5,.5,-.5],tColor,'EdgeColor',[160,160,160]./255,'LineWidth',1.2)
        if isnan(Data(i,j))
            plot(ax1,j+[-.5,.5,.5,-.5],i+[-.5,.5,-.5,.5],'Color',[160,160,160]./255,'LineWidth',1.2)
        end
    end
end
% colorbar 绘制
ax1.Colormap=CM1;
ax1.CLim=CLim1;
ax1.Colormap=CM1;
cbHdl1=colorbar(ax1,'north','LineWidth',.8);
cbHdl1.Position=[ax1.Position(1),.05,ax1.Position(3),cbHdl1.Position(4)];
cbHdl1.XAxisLocation='bottom';
% nan 图例绘制
nanFillHdl=fill(ax1,[-.5,-.5,.5,.5]-100,[-.5,.5,.5,-.5],[205,205,205]./255,'EdgeColor',[160,160,160]./255,'LineWidth',1.2);
lgdHdl1=legend(ax1,nanFillHdl,'NaN');
lgdHdl1.Box='off';
lgdHdl1.Position(1)=ax1.Position(1)+ax1.Position(3);
lgdHdl1.Position(2)=cbHdl1.Position(2);
lgdHdl1.Position(4)=cbHdl1.Position(4);
lgdHdl1.ItemTokenSize=lgdHdl1.ItemTokenSize(2).*[1,1];


%% ========================================================================
% 绘制气泡图

CLim2=[min(min(Data)),max(max(Data))];
% 生成颜色映射函数
CMX2=linspace(CLim2(1),CLim2(2),size(CM2,1))';
colorFunc2=@(X)[interp1(CMX2,CM2(:,1),X,'pchip'),interp1(CMX2,CM2(:,2),X,'pchip'),interp1(CMX2,CM2(:,3),X,'pchip')];
% 绘图
bubblechart(ax2,log2fc(:).*0,1:length(log2fc(:)),log2fc(:),negLog10pValue(:),'LineWidth',1,'MarkerEdgeColor',[0,0,0],'MarkerFaceAlpha',1)
bubblesize([15 40])
% 调整 colormap 范围
CLim2=[min(min(negLog10pValue)),max(max(negLog10pValue))];
ax2.Colormap=CM2;
ax2.CLim=CLim2;
% 绘制 bubblechart legend
bLgdHdl=bubblelegend(ax2);
bLgdHdl.Position(1)=ax2.Position(1)+ax2.Position(3).*1.1;
bLgdHdl.Position(2)=ax2.Position(2)+ax2.Position(4).*.65;
bLgdHdl.Box='off';
bLgdHdl.FontName='Cambria';
bLgdHdl.FontSize=12;
% 绘制 colorbar
cbHdl2=colorbar(ax2,'east','LineWidth',.8);
cbHdl2.Position(1)=bLgdHdl.Position(1)+bLgdHdl.Position(3)/5.5;
cbHdl2.Position(2)=ax2.Position(2);
cbHdl2.Position(4)=ax2.Position(4).*.55;
cbHdl2.YAxisLocation='right';
cbHdl2.Position(3)=.032;

% 绘制 colorbar 及 bubblechart legend 的 title
annotation(gcf,'textbox',[ax2.Position(1)+ax2.Position(3).*1.1,ax2.Position(2)+ax2.Position(4).*.95,.01,.01],...
    'String','log2fc','HorizontalAlignment','left','VerticalAlignment','middle','FontSize',16,'FontName','Cambria',...
    'FontWeight','bold','LineStyle','none')
annotation(gcf,'textbox',[ax2.Position(1)+ax2.Position(3).*1.05,ax2.Position(2)+ax2.Position(4).*.58,.01,.01],...
    'String','-log10(pvalue)','HorizontalAlignment','left','VerticalAlignment','middle','FontSize',16,'FontName','Cambria',...
    'FontWeight','bold','LineStyle','none')

