% 边际图示例
% marginalPlotDemo
% @author : slandarer
% Zhaoxu Liu / slandarer (2023). marginal plot 
% (https://www.mathworks.com/matlabcentral/fileexchange/123470-marginal-plot), 
% MATLAB Central File Exchange. 检索来源 2023/1/19.


% 构造三个符合高斯分布的点集
PntSet1=mvnrnd([2 3],[1 0;0 2],300);
PntSet2=mvnrnd([6 7],[1 0;0 2],300);
PntSet3=mvnrnd([14 9],[1 0;0 1],300);
% 将数据放进元胞数组
PntSet={PntSet1,PntSet2,PntSet3};
% -------------------------------------------------------------------------
% 配色预设(here to change the default color list)
C1=[211 43 43;61 96 137;249 206 61;76 103 86;80 80 80]./255;
C2=[102,173,194;36,59,66;232,69,69;194,148,102;54,43,33]./255;
C3=[223,122,94;60 64 91;130 178 154;244,241,222;240 201 134]./255;
C4=[122,117,119;255,163,25;135,146,73;126,15,4;30,93,134]./255;
C5=[198,199,201;38,74,96;209,80,51;241,174,44;12,13,15]./255;
C6=[235,75,55;77,186,216;58,84,141;2,162,136;245,155,122]./255;
C7=[23,23,23;121,17,36;31,80,91;44,9,75;61,36,42]./255;
C8=[47,62,66;203,129,70;0 64 115;152,58,58;20 72 83]./255;
colorList=C8;
% -------------------------------------------------------------------------
% 在这改边缘图及中心图种类
% (here to change the type of marginal plot and main plot)
%    |
%    |
%    |
% \  |  /
%  \ | /
%   \|/
%     
mainType=1;
marginType=1;
%  
%   /|\
%  / | \
% /  |  \
%    |
%    |
%    |
%% =========================================================================
% figure图床及主要区域axes坐标区域创建及基础修饰
fig=figure('Units','normalized','Position',[.3,.2,.5,.63]);
axM=axes('Parent',fig);hold on;
set(axM,'Position',[.08,.08,.65,.65],'LineWidth',1.1,'Box','on','TickDir','in',...
    'XMinorTick','on','YMinorTick','on','XGrid','on','YGrid','on','GridLineStyle','--',...
    'FontName','Times New Roman','FontSize',12,'GridAlpha',.09)
axM.XLabel.String='Main XXXXX';
axM.YLabel.String='Main YYYYY';
axM.XLabel.FontSize=14;
axM.YLabel.FontSize=14;
% -------------------------------------------------------------------------
% 右侧axes坐标区域创建及基础修饰
axR=axes('Parent',fig);hold on;
set(axR,'Position',[.75,.08,.23,.65],'LineWidth',1.1,'Box','off','TickDir','out',...
    'XMinorTick','on','YMinorTick','on','XGrid','on','YGrid','on','GridLineStyle','--',...
    'FontName','Times New Roman','FontSize',12,'GridAlpha',.09,'TickLength',[.006 .015],'YTickLabel','')
axR.XLabel.String='Y-axis data statistics';
axR.XLabel.FontSize=14;
% -------------------------------------------------------------------------
% 上方axes坐标区域创建及基础修饰
axU=axes('Parent',fig);hold on;
set(axU,'Position',[.08,.76,.65,.2],'LineWidth',1.1,'Box','off','TickDir','out',...
    'XMinorTick','on','YMinorTick','on','XGrid','on','YGrid','on','GridLineStyle','--',...
    'FontName','Times New Roman','FontSize',12,'GridAlpha',.09,'TickLength',[.006 .015],'XTickLabel','')
axU.YLabel.String='X-axis data statistics';
axU.YLabel.FontSize=14;
%% =========================================================================
% 主要区域散点图绘制
switch mainType
    case 1 % 散点图
        for i=1:length(PntSet)
            tPntSet=PntSet{i};
            scatter(axM,tPntSet(:,1),tPntSet(:,2),70,'filled','CData',colorList(i,:),'MarkerFaceAlpha',.6)
        end
        legendStr{length(PntSet)}='';
        for i=1:length(PntSet)
            legendStr{i}=['Class-',num2str(i)];
        end
        legend(axM,legendStr,'FontSize',14,'Box','off','Location','best');
    case 2 % 等高线图
        for i=1:length(PntSet)
            tPntSet=PntSet{i};
            gridx1=linspace(min(tPntSet(:,1)),max(tPntSet(:,1)),round(sqrt(size(tPntSet,1))));
            gridx2=linspace(min(tPntSet(:,2)),max(tPntSet(:,2)),round(sqrt(size(tPntSet,1))));
            [x1,x2]=meshgrid(gridx1, gridx2);
            [m,n]=size(x1);
            x1=x1(:);
            x2=x2(:);
            xi=[x1,x2];
            h=ksdensity(tPntSet,xi);
            contour(axM,reshape(x1,[m,n]),reshape(x2,[m,n]),reshape(h,[m,n]),...
                'LineWidth',1.2,'EdgeColor',colorList(i,:))
        end
        legendStr{length(PntSet)}='';
        for i=1:length(PntSet)
            legendStr{i}=['Class-',num2str(i)];
        end
        legend(axM,legendStr,'FontSize',14,'Box','off','Location','best');
    case 3 % 回归曲线
        for i=1:length(PntSet)
            tPntSet=PntSet{i};
            [p,S]=polyfit(tPntSet(:,1),tPntSet(:,2),1); 
            x1=linspace(min(tPntSet(:,1)),max(tPntSet(:,1)),100);
            [y_fit,delta]=polyval(p,x1,S);
            % 绘制原始数据、线性拟合和 95% 预测区间 y±2Δ。
            uy=y_fit+2.*delta;
            dy=y_fit-2.*delta;
            % 绘制原始数据
            sHdl(i)=scatter(axM,tPntSet(:,1),tPntSet(:,2),30,'filled','CData',colorList(i,:),'MarkerFaceAlpha',.9);
            % 绘制拟合曲线
            plot(axM,x1,y_fit,'Color',colorList(i,:),'LineWidth',2.5)
            % 绘制置信区间
            fill(axM,[x1,x1(end:-1:1)],[uy,dy(end:-1:1)],colorList(i,:),'EdgeColor','none','FaceAlpha',.15)
        end
        legendStr{length(PntSet)}='';
        for i=1:length(PntSet)
            legendStr{i}=['Class-',num2str(i)];
        end
        legend(axM,sHdl,legendStr,'FontSize',14,'Box','off','Location','best');
    case 4 % 散点+凸包
        for i=1:length(PntSet)
            tPntSet=PntSet{i};
            [k,av]=convhull(tPntSet);
            sHdl(i)=scatter(axM,tPntSet(:,1),tPntSet(:,2),30,'filled','CData',colorList(i,:),'MarkerFaceAlpha',.9);
            fill(axM,tPntSet(k,1),tPntSet(k,2),colorList(i,:),'FaceAlpha',0.3,'EdgeColor',colorList(i,:),'LineWidth',2)
        end
        legendStr{length(PntSet)}='';
        for i=1:length(PntSet)
            legendStr{i}=['Class-',num2str(i)];
        end
        legend(axM,sHdl,legendStr,'FontSize',14,'Box','off','Location','best');
    case 5 % 散点+不规则图形
        for i=1:length(PntSet)
            tPntSet=PntSet{i};
            sHdl(i)=scatter(axM,tPntSet(:,1),tPntSet(:,2),30,'filled','CData',colorList(i,:),'MarkerFaceAlpha',.9);
            R=max(max(tPntSet(:,1))-min(tPntSet(:,1)),max(tPntSet(:,2))-min(tPntSet(:,2)))./round(sqrt(size(tPntSet,1)));
            t=linspace(0,2*pi,100);
            [k,~]=convhull(tPntSet);
            kPntSet=tPntSet(k,:);
            kX=repmat(kPntSet(:,1),[1,100])+repmat(cos(t).*R,[length(k),1]);
            kY=repmat(kPntSet(:,2),[1,100])+repmat(sin(t).*R,[length(k),1]);
            kX=kX(:);kY=kY(:);
            [k,av]=convhull([kX,kY]);
            fill(axM,kX(k),kY(k),colorList(i,:),'FaceAlpha',0.3,'EdgeColor',colorList(i,:),'LineWidth',2)
        end
        legendStr{length(PntSet)}='';
        for i=1:length(PntSet)
            legendStr{i}=['Class-',num2str(i)];
        end
        legend(axM,sHdl,legendStr,'FontSize',14,'Box','off','Location','best');
    case 6 % 椭圆形
        for i=1:length(PntSet)
            tPntSet=PntSet{i};
            sHdl(i)=scatter(axM,tPntSet(:,1),tPntSet(:,2),30,'filled','CData',colorList(i,:),'MarkerFaceAlpha',.9);
            Mu=mean(tPntSet);
            Y=tPntSet-repmat(Mu,size(tPntSet,1),1);
            Sigma=cov(Y);% Sigma=(Y'*(ones(size(pntSet,1),1).*Y))./(size(pntSet,1)-1);
            [X,Y]=getEllipse(Mu,Sigma,9.21,100);
            fill(axM,X,Y,colorList(i,:),'FaceAlpha',0.3,'EdgeColor',colorList(i,:),'LineWidth',2);
        end
        legendStr{length(PntSet)}='';
        for i=1:length(PntSet)
            legendStr{i}=['Class-',num2str(i)];
        end
        legend(axM,sHdl,legendStr,'FontSize',14,'Box','off','Location','best');
    case 7 % 簇状
        for i=1:length(PntSet)
            tPntSet=PntSet{i};
            sHdl(i)=scatter(axM,tPntSet(:,1),tPntSet(:,2),30,'filled','CData',colorList(i,:),'MarkerFaceAlpha',.9);
            Mu=mean(tPntSet);
            LX=[tPntSet(:,1),Mu(1).*ones(size(tPntSet,1),1),nan(size(tPntSet,1),1)]';
            LY=[tPntSet(:,2),Mu(2).*ones(size(tPntSet,1),1),nan(size(tPntSet,1),1)]';
            plot(axM,LX(:),LY(:),'Color',colorList(i,:),'LineWidth',1.2);
        end
        legendStr{length(PntSet)}='';
        for i=1:length(PntSet)
            legendStr{i}=['Class-',num2str(i)];
        end
        legend(axM,sHdl,legendStr,'FontSize',14,'Box','off','Location','best');
    case 8 % 误差棒
        for i=1:length(PntSet)
            tPntSet=PntSet{i};
            Mu=mean(tPntSet);
            SX=std(tPntSet(:,1));
            SY=std(tPntSet(:,2));
            errorbar(axM,Mu(1),Mu(2),SY,SY,SX,SX,'o','LineWidth',1.5,'Color',colorList(i,:),'MarkerSize',10);
        end
        legendStr{length(PntSet)}='';
        for i=1:length(PntSet)
            legendStr{i}=['Class-',num2str(i)];
        end
        legend(axM,legendStr,'FontSize',14,'Box','off','Location','best');
end
% -------------------------------------------------------------------------
% 边际图绘制
axR.YLim=axM.YLim;
axU.XLim=axM.XLim;
for i=1:length(PntSet)
tPntSet=PntSet{i};
switch marginType
    case 1 % 柱状图
        histogram(axR,tPntSet(:,2),'FaceColor',colorList(i,:),'Orientation','horizontal',...
            'EdgeColor',[1 1 1]*.1,'FaceAlpha',0.6,'LineWidth',.8)
        histogram(axU,tPntSet(:,1),'FaceColor',colorList(i,:),...
            'EdgeColor',[1 1 1]*.1,'FaceAlpha',0.6,'LineWidth',.8)
    case 2 % 核密度面
        [f,yi]=ksdensity(tPntSet(:,2));
        fill(axR,[f,0],[yi,yi(1)],colorList(i,:),...
            'FaceAlpha',0.3,'EdgeColor','none')
        [f,xi]=ksdensity(tPntSet(:,1));
        fill(axU,[xi,xi(1)],[f,0],colorList(i,:),...
            'FaceAlpha',0.3,'EdgeColor','none')
    case 3 % 核密度线
        [f,yi]=ksdensity(tPntSet(:,2));
        plot(axR,f,yi,'Color',colorList(i,:),'LineWidth',2)
        [f,xi]=ksdensity(tPntSet(:,1));
        plot(axU,xi,f,'Color',colorList(i,:),'LineWidth',2)
    case 4 % 核密度面+线
        [f,yi]=ksdensity(tPntSet(:,2));
        fill(axR,[f,0],[yi,yi(1)],colorList(i,:),...
            'FaceAlpha',0.3,'EdgeColor','none');
        plot(axR,f,yi,'Color',colorList(i,:),'LineWidth',1.2)
        [f,xi]=ksdensity(tPntSet(:,1));
        fill(axU,[xi,xi(1)],[f,0],colorList(i,:),...
            'FaceAlpha',0.3,'EdgeColor','none');
        plot(axU,xi,f,'Color',colorList(i,:),'LineWidth',1.2)
    case 5 % 直方图+密度线
        HR=histogram(axR,tPntSet(:,2),'FaceColor',colorList(i,:),'Orientation','horizontal',...
            'EdgeColor',[1 1 1]*.1,'FaceAlpha',0.6,'LineWidth',.8);
        HU=histogram(axU,tPntSet(:,1),'FaceColor',colorList(i,:),...
            'EdgeColor',[1 1 1]*.1,'FaceAlpha',0.6,'LineWidth',.8);
        [f,yi]=ksdensity(tPntSet(:,2));
        plot(axR,f.*size(tPntSet,1).*HR.BinWidth,yi,'Color',colorList(i,:),'LineWidth',2)
        [f,xi]=ksdensity(tPntSet(:,1));
        plot(axU,xi,f.*size(tPntSet,1).*HU.BinWidth,'Color',colorList(i,:),'LineWidth',2)
    case 6 % 箱线图
        tjDataY=tPntSet(:,2);fullDataY=tjDataY;
        outliBool=isoutlier(tjDataY,'quartiles');
        outli=tjDataY(outliBool);
        scatter(axR,repmat(i,[sum(outliBool),1]),outli,45,'filled',...
            'CData',colorList(i,:),'LineWidth',1.2,'MarkerFaceAlpha',0.8)
        tjDataY(outliBool)=[];
        qt25=quantile(fullDataY,0.25);
        qt75=quantile(fullDataY,0.75);
        med=median(fullDataY);
        plot(axR,[i,i],[max(tjDataY),qt75],'LineWidth',1.2,'Color',[0,0,0])
        plot(axR,[i,i],[min(tjDataY),qt25],'LineWidth',1.2,'Color',[0,0,0])
        plot(axR,[-.15,.15]+i,[max(tjDataY),max(tjDataY)],'LineWidth',1.2,'Color',[0,0,0])
        plot(axR,[-.15,.15]+i,[min(tjDataY),min(tjDataY)],'LineWidth',1.2,'Color',[0,0,0])
        plot(axR,[-.25,.25]+i,[med,med],'LineWidth',1.2,'Color',colorList(i,:))
        fill(axR,i+.25.*1.*[-1 1 1 -1],[qt25,qt25,qt75,qt75],colorList(i,:),...
            'FaceAlpha',0.3,'EdgeColor',colorList(i,:),'LineWidth',1.2);
        axR.XLim=[0,length(PntSet)+1];
        % -----------------------------------------------------------------
        tjDataX=tPntSet(:,1);fullDataX=tjDataX;
        outliBool=isoutlier(tjDataX,'quartiles');
        outli=tjDataX(outliBool);
        scatter(axU,outli,repmat(i,[sum(outliBool),1]),45,'filled',...
            'CData',colorList(i,:),'LineWidth',1.2,'MarkerFaceAlpha',0.8)
        tjDataX(outliBool)=[];
        qt25=quantile(fullDataX,0.25);
        qt75=quantile(fullDataX,0.75);
        med=median(fullDataX);
        plot(axU,[max(tjDataX),qt75],[i,i],'LineWidth',1.2,'Color',[0,0,0])
        plot(axU,[min(tjDataX),qt25],[i,i],'LineWidth',1.2,'Color',[0,0,0])
        plot(axU,[max(tjDataX),max(tjDataX)],[-.15,.15]+i,'LineWidth',1.2,'Color',[0,0,0])
        plot(axU,[min(tjDataX),min(tjDataX)],[-.15,.15]+i,'LineWidth',1.2,'Color',[0,0,0])
        plot(axU,[med,med],[-.25,.25]+i,'LineWidth',1.2,'Color',colorList(i,:))
        fill(axU,[qt25,qt25,qt75,qt75],i+.25.*1.*[-1 1 1 -1],colorList(i,:),...
            'FaceAlpha',0.3,'EdgeColor',colorList(i,:),'LineWidth',1.2);
        axU.YLim=[0,length(PntSet)+1];
    case 7 % 小提琴图
        tjDataY=tPntSet(:,2);fullDataY=tjDataY;
        [f,yi]=ksdensity(tjDataY);
        f(yi>max(tjDataY))=[];yi(yi>max(tjDataY))=[];
        f(yi<min(tjDataY))=[];yi(yi<min(tjDataY))=[];
        fill(axR,[f,-f(end:-1:1)].*1.2+i,[yi,yi(end:-1:1)],colorList(i,:),'FaceAlpha',0.3,...
            'EdgeColor',colorList(i,:),'LineWidth',1.2);
        outliBool=isoutlier(tjDataY,'quartiles');
        outli=tjDataY(outliBool);
        scatter(axR,repmat(i,[sum(outliBool),1]),outli,45,'filled',...
            'CData',colorList(i,:),'LineWidth',1.2,'MarkerFaceAlpha',0.8)
        tjDataY(outliBool)=[];
        qt25=quantile(fullDataY,0.25);
        qt75=quantile(fullDataY,0.75);
        med=median(fullDataY);
        plot(axR,[i,i],[max(tjDataY),qt75],'LineWidth',1.2,'Color',[0,0,0])
        plot(axR,[i,i],[min(tjDataY),qt25],'LineWidth',1.2,'Color',[0,0,0])
        fill(axR,i+.2.*1.*[-1 1 1 -1],[qt25,qt25,qt75,qt75],[1,1,1],...
            'FaceAlpha',0.95,'EdgeColor',colorList(i,:),'LineWidth',1.2);
        plot(axR,[-.2,.2]+i,[med,med],'LineWidth',1.2,'Color',colorList(i,:))
        axR.XLim=[0,length(PntSet)+1];
        % -----------------------------------------------------------------
        tjDataX=tPntSet(:,1);fullDataX=tjDataX;
        [f,xi]=ksdensity(tjDataX);
        f(xi>max(tjDataX))=[];xi(xi>max(tjDataX))=[];
        f(xi<min(tjDataX))=[];xi(xi<min(tjDataX))=[];
        fill(axU,[xi,xi(end:-1:1)],[f,-f(end:-1:1)].*1.2+i,colorList(i,:),'FaceAlpha',0.3,...
            'EdgeColor',colorList(i,:),'LineWidth',1.2);
        outliBool=isoutlier(tjDataX,'quartiles');
        outli=tjDataX(outliBool);
        scatter(axU,outli,repmat(i,[sum(outliBool),1]),45,'filled',...
            'CData',colorList(i,:),'LineWidth',1.2,'MarkerFaceAlpha',0.8)
        tjDataX(outliBool)=[];
        qt25=quantile(fullDataX,0.25);
        qt75=quantile(fullDataX,0.75);
        med=median(fullDataX);
        plot(axU,[max(tjDataX),qt75],[i,i],'LineWidth',1.2,'Color',[0,0,0])
        plot(axU,[min(tjDataX),qt25],[i,i],'LineWidth',1.2,'Color',[0,0,0])
        fill(axU,[qt25,qt25,qt75,qt75],i+.25.*1.*[-1 1 1 -1],[1,1,1],...
            'FaceAlpha',0.95,'EdgeColor',colorList(i,:),'LineWidth',1.2);
        plot(axU,[med,med],[-.25,.25]+i,'LineWidth',1.2,'Color',colorList(i,:))
        axU.YLim=[0,length(PntSet)+1];
    case 8 % 线条散点
        LY=[tPntSet(:,2),tPntSet(:,2),tPntSet(:,2).*nan]';
        LX=repmat([i-.3,i+.3,nan],[size(tPntSet,1),1])';
        line(axR,LX(:),LY(:),'Color',[colorList(i,:),.4],'lineWidth',1)
        axR.XLim=[0,length(PntSet)+1];
        LX=[tPntSet(:,1),tPntSet(:,1),tPntSet(:,1).*nan]';
        LY=repmat([i-.3,i+.3,nan],[size(tPntSet,1),1])';
        line(axU,LX(:),LY(:),'Color',[colorList(i,:),.4],'lineWidth',1)
        axU.YLim=[0,length(PntSet)+1];
    case 9 % 山脊图
        [f,yi]=ksdensity(tPntSet(:,2));
        fill(axR,[f,0]+(i-1).*.5,[yi,yi(1)],colorList(i,:),...
            'FaceAlpha',0.3,'EdgeColor','none');
        plot(axR,f+(i-1).*.5,yi,'Color',colorList(i,:),'LineWidth',1.2)
        [f,xi]=ksdensity(tPntSet(:,1));
        fill(axU,[xi,xi(1)],[f,0]+(i-1).*.5,colorList(i,:),...
            'FaceAlpha',0.3,'EdgeColor','none');
        plot(axU,xi,f+(i-1).*.5,'Color',colorList(i,:),'LineWidth',1.2)
    case 10 % 类小提琴图
        tjDataY=tPntSet(:,2);fullDataY=tjDataY;
        [f,yi]=ksdensity(tjDataY);
        f(yi>max(tjDataY))=[];yi(yi>max(tjDataY))=[];
        f(yi<min(tjDataY))=[];yi(yi<min(tjDataY))=[];
        fill(axR,[0,f,0].*1.2+i+.15,[yi(1),yi,yi(end)],colorList(i,:),'FaceAlpha',0.3,...
            'EdgeColor',colorList(i,:),'LineWidth',1.2);
        outliBool=isoutlier(tjDataY,'quartiles');
        outli=tjDataY(outliBool);
        scatter(axR,repmat(i-.15,[sum(outliBool),1]),outli,45,'filled',...
            'CData',colorList(i,:),'LineWidth',1.2,'MarkerFaceAlpha',0.8)
        tjDataY(outliBool)=[];
        qt25=quantile(fullDataY,0.25);
        qt75=quantile(fullDataY,0.75);
        med=median(fullDataY);
        plot(axR,[i,i]-.2,[max(tjDataY),qt75],'LineWidth',1.2,'Color',[0,0,0])
        plot(axR,[i,i]-.2,[min(tjDataY),qt25],'LineWidth',1.2,'Color',[0,0,0])
        fill(axR,i-.2+.2.*1.*[-1 1 1 -1],[qt25,qt25,qt75,qt75],[1,1,1],...
            'FaceAlpha',0.95,'EdgeColor',colorList(i,:),'LineWidth',1.2);
        plot(axR,[-.2,.2]+i-.2,[med,med],'LineWidth',1.2,'Color',colorList(i,:))
        axR.XLim=[0,length(PntSet)+1];
        % -----------------------------------------------------------------
        tjDataX=tPntSet(:,1);fullDataX=tjDataX;
        [f,xi]=ksdensity(tjDataX);
        f(xi>max(tjDataX))=[];xi(xi>max(tjDataX))=[];
        f(xi<min(tjDataX))=[];xi(xi<min(tjDataX))=[];
        fill(axU,[xi(1),xi,xi(end)],[0,f,0].*1.2+i+.15,colorList(i,:),'FaceAlpha',0.3,...
            'EdgeColor',colorList(i,:),'LineWidth',1.2);
        outliBool=isoutlier(tjDataX,'quartiles');
        outli=tjDataX(outliBool);
        scatter(axU,outli,repmat(i-.2,[sum(outliBool),1]),45,'filled',...
            'CData',colorList(i,:),'LineWidth',1.2,'MarkerFaceAlpha',0.8)
        tjDataX(outliBool)=[];
        qt25=quantile(fullDataX,0.25);
        qt75=quantile(fullDataX,0.75);
        med=median(fullDataX);
        plot(axU,[max(tjDataX),qt75],[i,i]-.2,'LineWidth',1.2,'Color',[0,0,0])
        plot(axU,[min(tjDataX),qt25],[i,i]-.2,'LineWidth',1.2,'Color',[0,0,0])
        fill(axU,[qt25,qt25,qt75,qt75],i-.2+.25.*1.*[-1 1 1 -1],[1,1,1],...
            'FaceAlpha',0.95,'EdgeColor',colorList(i,:),'LineWidth',1.2);
        plot(axU,[med,med],[-.25,.25]+i-.2,'LineWidth',1.2,'Color',colorList(i,:))
        axU.YLim=[0,length(PntSet)+1];
    case 11 % 雨云图
        tjDataY=tPntSet(:,2);fullDataY=tjDataY;
        [f,yi]=ksdensity(tjDataY);
        f(yi>max(tjDataY))=[];yi(yi>max(tjDataY))=[];
        f(yi<min(tjDataY))=[];yi(yi<min(tjDataY))=[];
        fill(axR,[0,f,0].*1.2+i+.15,[yi(1),yi,yi(end)],colorList(i,:),'FaceAlpha',0.3,...
            'EdgeColor',colorList(i,:),'LineWidth',1.2);
        scatter(axR,tPntSet(:,2).*0+i-.2+.22.*(rand(size(tPntSet,1),1)-.5).*2,tPntSet(:,2),45,'filled',...
            'CData',colorList(i,:),'LineWidth',1.2,'MarkerFaceAlpha',0.3)
        tjDataY(outliBool)=[];
        qt25=quantile(fullDataY,0.25);
        qt75=quantile(fullDataY,0.75);
        med=median(fullDataY);
        plot(axR,[i,i]-.2,[max(tjDataY),qt75],'LineWidth',1.2,'Color',[0,0,0])
        plot(axR,[i,i]-.2,[min(tjDataY),qt25],'LineWidth',1.2,'Color',[0,0,0])
        fill(axR,i-.2+.2.*1.*[-1 1 1 -1],[qt25,qt25,qt75,qt75],[1,1,1],...
            'FaceAlpha',0.95,'EdgeColor',colorList(i,:),'LineWidth',1.2);
        plot(axR,[-.2,.2]+i-.2,[med,med],'LineWidth',1.2,'Color',colorList(i,:))
        axR.XLim=[0,length(PntSet)+1];
        % -----------------------------------------------------------------
        tjDataX=tPntSet(:,1);fullDataX=tjDataX;
        [f,xi]=ksdensity(tjDataX);
        f(xi>max(tjDataX))=[];xi(xi>max(tjDataX))=[];
        f(xi<min(tjDataX))=[];xi(xi<min(tjDataX))=[];
        fill(axU,[xi(1),xi,xi(end)],[0,f,0].*1.2+i+.15,colorList(i,:),'FaceAlpha',0.3,...
            'EdgeColor',colorList(i,:),'LineWidth',1.2);
        scatter(axU,tPntSet(:,1),tPntSet(:,1).*0+i-.2+.22.*(rand(size(tPntSet,1),1)-.5),45,'filled',...
            'CData',colorList(i,:),'LineWidth',1.2,'MarkerFaceAlpha',0.3)
        tjDataX(outliBool)=[];
        qt25=quantile(fullDataX,0.25);
        qt75=quantile(fullDataX,0.75);
        med=median(fullDataX);
        plot(axU,[max(tjDataX),qt75],[i,i]-.2,'LineWidth',1.2,'Color',[0,0,0])
        plot(axU,[min(tjDataX),qt25],[i,i]-.2,'LineWidth',1.2,'Color',[0,0,0])
        fill(axU,[qt25,qt25,qt75,qt75],i-.2+.25.*1.*[-1 1 1 -1],[1,1,1],...
            'FaceAlpha',0.95,'EdgeColor',colorList(i,:),'LineWidth',1.2);
        plot(axU,[med,med],[-.25,.25]+i-.2,'LineWidth',1.2,'Color',colorList(i,:))
        axU.YLim=[0,length(PntSet)+1];
end
end
linkaxes([axM,axR],'y')
linkaxes([axM,axU],'x')
%% ========================================================================
% 所使用到的函数
% 置信椭圆定位函数
function [X,Y]=getEllipse(Mu,Sigma,S,pntNum)
% 置信区间 | 95%:5.991  99%:9.21  90%:4.605
% (X-Mu)*inv(Sigma)*(X-Mu)=S

invSig=inv(Sigma);

[V,D]=eig(invSig);
aa=sqrt(S/D(1));
bb=sqrt(S/D(4));

t=linspace(0,2*pi,pntNum);
XY=V*[aa*cos(t);bb*sin(t)];
X=(XY(1,:)+Mu(1))';
Y=(XY(2,:)+Mu(2))';
end
% Zhaoxu Liu / slandarer (2023). marginal plot 
% (https://www.mathworks.com/matlabcentral/fileexchange/123470-marginal-plot), 
% MATLAB Central File Exchange. 检索来源 2023/1/19.
