function rainCloudsTMPL2
% @author: slandarer


% 在这里放入你的数据=======================================================
X1=[normrnd(8,4,1,120),normrnd(5,2,1,25)];
X2=[normrnd(2.5,3,1,75),normrnd(6,4,1,25),normrnd(15,1,1,100)];
X3=[normrnd(4,3,1,40),normrnd(3,4,1,25)];
X4=[normrnd(4,3,1,40),normrnd(2,4,1,75)];

dataCell={X1,X2,X3,X4};  % 把数据放到元胞数组，要是数据太多可写循环放入  
dataName={'A','B','C','D'};  % 各个数据类的名称，可空着

% 颜色列表
colorList=[0.9294    0.7569    0.5059
           0.9176    0.5569    0.4627
           0.7020    0.4784    0.5451
           0.4863    0.4314    0.5490];      
% =========================================================================

classNum=length(dataCell);
if size(colorList,1)==0
    colorList=repmat([130,170,172]./255,[classNum,1]);
else
    colorList=repmat(colorList,[ceil(classNum/size(colorList,1)),1]);
end
if isempty(dataName)
    for i=1:classNum
        dataName{i}=['class',num2str(i)];
    end
end

% 坐标区域修饰
hold on
ax=gca;
ax.XLim=[1/2,classNum+2/3];
ax.XTick=1:classNum;
ax.LineWidth=1.2;
ax.XTickLabels=dataName(end:-1:1);
ax.FontSize=14;




rate=3.5;


% 绘制雨云图
for i=1:classNum
    tX=dataCell{i};tX=tX(:);
    [F,Xi]=ksdensity(tX);

    % 绘制山脊图
    patchCell(i)=fill(0.2+[0,F,0].*rate+(classNum+1-i).*ones(1,length(F)+2),[Xi(1),Xi,Xi(end)],...
        colorList(i,:),'EdgeColor',[0,0,0],'FaceAlpha',0.8,'LineWidth',1.2);

    % 其他数据获取
    qt25=quantile(tX,0.25); % 下四分位数
    qt75=quantile(tX,0.75); % 上四分位数 
    med=median(tX);         % 中位数

    outliBool=isoutlier(tX,'quartiles');  % 离群值点
    nX=tX(~outliBool);                    % 95%置信内的数
    
    % 绘制箱线图
    plot([(classNum+1-i),(classNum+1-i)],[min(nX),max(nX)],'k','lineWidth',1.2);
    fill((classNum+1-i)+[-1 1 1 -1].*0.12,[qt25,qt25,qt75,qt75],colorList(i,:),'EdgeColor',[0 0 0]);
    plot([(classNum+1-i)-0.12,(classNum+1-i)+0.12],[med,med],'Color',[0,0,0],'LineWidth',2.5)

    % 绘制散点 
    tY=(rand(length(tX),1)-0.5).*0.24+ones(length(tX),1).*(classNum+1-i);
    scatter(tY,tX,15,'CData',colorList(i,:),'MarkerEdgeAlpha',0.15,...
        'MarkerFaceColor',colorList(i,:),'MarkerFaceAlpha',0.1)
end

lgd=legend(patchCell,dataName);
lgd.Location='best';
end