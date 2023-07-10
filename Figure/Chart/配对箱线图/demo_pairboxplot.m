% pairboxplot

% 随机构造一组数据
PntSet1=sort(mvnrnd(0,2,25));
PntSet2=sort(mvnrnd(.5,2.5,25));
PntSet3=sort(mvnrnd(0,2,25));
PntSet4=sort(mvnrnd(.5,2.5,25));
% Y=[PntSet1,PntSet2];
Y=[PntSet1,PntSet2,PntSet3,PntSet4];

% 配色列表
C1=[59 125 183;244 146 121;242 166 31;180 68 108;220 211 30]./255;
C2=[102,173,194;36,59,66;232,69,69;194,148,102;54,43,33]./255;
C3=[38,140,209;219,51,46;41,161,153;181,138,0;107,112,196]./255;
C4=[110,153,89;230,201,41;79,79,54;245,245,245;199,204,158]./255;
C5=[235,75,55;77,186,216;2,162,136;58,84,141;245,155,122]./255;
C6=[23,23,23;121,17,36;44,9,75;31,80,91;61,36,42]./255;
C7=[126,15,4;122,117,119;255,163,25;135,146,73;30,93,134]./255;
colorList=C7;


% 绘图
boxplot(Y,'Symbol','o','OutlierSize',3,'Colors',[0,0,0]);

% 坐标区域属性设置
ax=gca;hold on;
ax.LineWidth=1.1;
ax.FontSize=11;
ax.FontName='Arial';
ax.XTickLabel={'AA','BB','CC','DD','EE','FF'};
ax.Title.String='Title of Paired BoxPlot';
ax.Title.FontSize=13;
ax.YLabel.String='expression of XXX';

% 修改线条粗细
lineObj=findobj(gca,'Type','Line');
for i=1:length(lineObj)
    lineObj(i).LineWidth=1;
    lineObj(i).MarkerFaceColor=[1,1,1].*.3;
    lineObj(i).MarkerEdgeColor=[1,1,1].*.3;
end

% 为箱线图的框上色
boxObj=findobj(gca,'Tag','Box');
for i=1:length(boxObj)
    patch(boxObj(i).XData,boxObj(i).YData,colorList(length(boxObj)+1-i,:),'FaceAlpha',0.5,...
        'LineWidth',1.1);
end

% 绘制配对线
X=ones(size(Y)).*(1:size(Y,2));
plot(X',Y','Color',[0,0,0,.3],'Marker','o','MarkerFaceColor',[1,1,1].*.3,...
    'MarkerEdgeColor',[1,1,1].*.3,'MarkerSize',3,'LineWidth',.6)