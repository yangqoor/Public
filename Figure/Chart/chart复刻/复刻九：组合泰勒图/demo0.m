clc; clear
Data = load('testData.mat');
Data = Data.Data(:,1:end-1);

% Calculate STD RMSD and COR(计算标准差、中心均方根误差、相关系数)
STATS = zeros(4,size(Data,2));
for i = 1:size(Data,2)
    STATS(:,i) = SStats(Data(:,1),Data(:,i));
end
STATS(1,:) = [];
STATS=STATS(:,[1,3]);

% Create taylor axes(生成泰勒图坐标区域)
figure('Units','normalized','Position',[.2,.1,.52,.72]);
TD = STaylorDiag(STATS);
TD.set('STickValues',[0    40    80   120   170 ]);

% Color list(颜色列表)
colorList = [0.3569    0.0784    0.0784
    0.3569    0.0784    0.0784];
MarkerType={'o','o','pentagram','^','v'};
% Plot(绘制散点图)
for i = 1:2
    plt(i)=TD.SPlot(STATS(1,i),STATS(2,i),STATS(3,i),'Marker',MarkerType{i},'MarkerSize',10,...
        'Color',colorList(i,:),'MarkerFaceColor',colorList(i,:));
end

plot([0,plt(1).XData],[0,plt(1).YData],'LineWidth',2,'Color','b')
plot([0,plt(2).XData],[0,plt(2).YData],'LineWidth',2,'Color','b')
plot([plt(1).XData,plt(2).XData],[plt(1).YData,plt(2).YData],'LineWidth',2,'Color','b')

text(77,70,'$S_f$','FontSize',24,'FontWeight','bold','FontName','Times New Roman','Interpreter','latex')
text(95,-7,'$S_r$','FontSize',24,'FontWeight','bold','FontName','Times New Roman','Interpreter','latex')
text(165,47,'$R$','FontSize',24,'FontWeight','bold','FontName','Times New Roman','Interpreter','latex')
text(25,8,'$\arccos(C)$','FontSize',24,'FontWeight','bold','FontName','Times New Roman','Interpreter','latex','Color',[.8,0,0])

t=linspace(0,pi/5.25);
plot(cos(t).*20,sin(t).*20,'LineWidth',3,'Color',[.8,0,0])





