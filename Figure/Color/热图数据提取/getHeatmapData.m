function getHeatmapData
% 要提取的图像地址
picPath='7.png';
% 提取结果存储路径
HMPath='data7.mat';
% 热图行数、列数
heatMapSize=[8,8];
% colorbar所表示范围
climColorbar=[-1,1];
% 提取colorbar上颜色点数量
pntNumColorBar=20;
% 数据计算所用点数(数值越大越精确)
pntNumInterp=1000;



% figure窗口初始化
pic=imread(picPath);
figure()
ax=gca;hold on
ax.XLim=[0,size(pic,2)];
ax.YLim=[0,size(pic,1)];
imshow(pic)
% 绘制红蓝色点的句柄
baHdl=plot(ax,0,0,'b+','MarkerSize',12,'LineWidth',1.5);
rxHdl=plot(ax,0,0,'rx','MarkerSize',12,'LineWidth',1.5);
pntSet=zeros(0,2);
colorSet=zeros(4,3);
set(gcf,'WindowButtonDownFcn',@buttondown)

    function buttondown(~,~)
        xy=get(gca,'CurrentPoint');
        xp=xy(1,2);yp=xy(1,1);pos=[yp,xp];
        if strcmp(get(gcf,'SelectionType'),'normal')
            pntSet=[pntSet;pos];
        elseif size(pntSet,1)>0
            pntSet(end,:)=[];
        end
        pntSet=round(pntSet);
        pntSet(pntSet<1)=1;
        if size(pntSet,1)>4
            set(gcf,'WindowButtonDownFcn',[])
            saveColor();
            close all
        else
        % 标记采样点位置和数值
        baHdl.XData=pntSet(:,1);baHdl.YData=pntSet(:,2);
        rxHdl.XData=pntSet(:,1);rxHdl.YData=pntSet(:,2);
        delete(findobj('type','text'))
        for i=1:size(pntSet,1)
            colorSet(i,:)=[pic(pntSet(i,2),pntSet(i,1),1),...
                           pic(pntSet(i,2),pntSet(i,1),2),...
                           pic(pntSet(i,2),pntSet(i,1),3)];
            text(ax,pntSet(i,1),pntSet(i,2),['    ',num2str(i),':[',num2str(colorSet(i,1)),',',...
                 num2str(colorSet(i,2)),',',num2str(colorSet(i,3)),']'])
        end
        end
    end
    function saveColor(~,~)
        % 获取colorbar上颜色
        cbPntSet=pntSet(1:2,:);
        cbPntSetdiff=abs(cbPntSet(1,:)-cbPntSet(2,:));
        if cbPntSetdiff(1)>cbPntSetdiff(2)
            tPntSet=cbPntSet(1,1)+linspace(0,1,pntNumColorBar)'.*(cbPntSet(2,1)-cbPntSet(1,1));
            tPntSet=round(tPntSet);
            CMap=[pic(round((cbPntSet(1,2)+cbPntSet(2,2))/2),tPntSet,1)',...
            pic(round((cbPntSet(1,2)+cbPntSet(2,2))/2),tPntSet,2)',...
            pic(round((cbPntSet(1,2)+cbPntSet(2,2))/2),tPntSet,3)'];
        else
            tPntSet=cbPntSet(1,2)+linspace(0,1,pntNumColorBar)'.*(cbPntSet(2,2)-cbPntSet(1,2));
            tPntSet=round(tPntSet);
            CMap=[pic(tPntSet,round((cbPntSet(1,1)+cbPntSet(2,1))/2),1),...
            pic(tPntSet,round((cbPntSet(1,1)+cbPntSet(2,1))/2),2),...
            pic(tPntSet,round((cbPntSet(1,1)+cbPntSet(2,1))/2),3)];
        end
        CMap=double(CMap);
        % -----------------------------------------------------------------
        % 提取heatmap上颜色
        hmPntSet=pntSet(3:4,:);
        hmXLim=[min(hmPntSet(:,1)),max(hmPntSet(:,1))];
        hmYLim=[min(hmPntSet(:,2)),max(hmPntSet(:,2))];
        YList=linspace(hmYLim(1),hmYLim(2),heatMapSize(1));
        XList=linspace(hmXLim(1),hmXLim(2),heatMapSize(2));
        [XMesh,YMesh]=meshgrid(round(XList),round(YList));
        CMesh=zeros(heatMapSize);
        for i=1:heatMapSize(1)
            for j=1:heatMapSize(2)
                CMesh(i,j,1)=pic(YMesh(i,j),XMesh(i,j),1);
                CMesh(i,j,2)=pic(YMesh(i,j),XMesh(i,j),2);
                CMesh(i,j,3)=pic(YMesh(i,j),XMesh(i,j),3);
            end
        end
        % 计算heatmap数值范围
        CMesh=double(CMesh);
        t1=linspace(climColorbar(1),climColorbar(2),pntNumColorBar)';
        t2=linspace(climColorbar(1),climColorbar(2),pntNumInterp)';
        CMapInterp=[interp1(t1,CMap(:,1),t2,'linear'),interp1(t1,CMap(:,2),t2,'linear'),interp1(t1,CMap(:,3),t2,'linear')];
        Data=zeros(heatMapSize);
        for i=1:heatMapSize(1)
            for j=1:heatMapSize(2)
                tRGB=[CMesh(i,j,1),CMesh(i,j,2),CMesh(i,j,3)];
                tnorm2=sum((CMapInterp-tRGB).^2,2);
                [ind,~]=find(tnorm2==min(tnorm2),1);
                Data(i,j)=t2(ind);
            end
        end
        % 存储数值
%         timestr=char(datetime('now'));
%         timestr(timestr==' ')='_';
%         timestr(timestr==':')='_';
%         nowStr=[timestr,'.mat'];
        CMapInterp=CMapInterp./255;
        CMap=CMap./255;
        save(HMPath,'Data','CMap','CMapInterp','climColorbar')
    end
end