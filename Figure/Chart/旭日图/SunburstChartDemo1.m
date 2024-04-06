% @author:slandarer

%% ========================================================================
% 随机生成一组数据，可将 Table 自行更换
rng(1)
ULList = 'ABCD';
LLList = 'abcd';

rowNum = 50;
idx1   = randi([1,length(ULList)],[1,rowNum]);
idx2   = randi([1,3],[rowNum,1]);
Name1  = ULList(idx1'*ones(1,4));
Name2  = [LLList(idx1'*ones(1,4)),num2str(idx2)];
Name3  = [LLList(idx1)',num2str(idx2),...
         char(45.*ones(rowNum,1)),char(randi([97,122],[rowNum,5]))];
Value  = rand([rowNum,1]);
Table  = table(Name1,Name2,Name3,Value);

%% ========================================================================
% 利用 grp2idx 进行分类，利用 sortrows 将相同类归在一起
NameList  = Table.Properties.VariableNames;
NameNum   = length(NameList)-1;
NameCell{NameNum} = ' ';
valueList = zeros(length(Table.(NameList{1})),NameNum);
for i = 1:NameNum-1
    tName = Table.(NameList{i});
    tUniq = unique(tName,'rows');
    NameCell{i} = tUniq;
    ind = grp2idx([tUniq;tName]);
    ind(1:length(tUniq)) = [];
    valueList(:,i) = ind;
end
valueList(:,end) = -Table.(NameList{end});
[VAL,IDX] = sortrows(valueList,1:size(valueList,2));
VAL(:,end) = -VAL(:,end);
%% ========================================================================
% 此处可以设置配色
CList=[0.3882    0.5333    0.7059
    1.0000    0.6824    0.2039
    0.9373    0.4353    0.4157
    0.5490    0.7608    0.7922
    0.3333    0.6784    0.5373
    0.7647    0.7373    0.2471
    0.7333    0.4627    0.5765
    0.7294    0.6275    0.5804
    0.6627    0.7098    0.6824
    0.4627    0.4627    0.4627];
% 在这可修改字体
FontProp = {'FontSize',12,'Color',[0,0,0]};
% 在这可设置比例低于多少的部分不显示文字
TextThreshold = 0.012;
%% ========================================================================
% 开始绘图
figure('Units','normalized','Position',[.2,.1,.52,.72]);
ax = gca; hold on
ax.DataAspectRatio = [1,1,1];
ax.XColor = 'none';
ax.YColor = 'none';
tT = linspace(0,1,100);
for i = 1:size(VAL,2)-1
    tRateSum = 0;
    tNum = length(NameCell{i});
    for j = 1:tNum
        tRate = sum(VAL(VAL(:,i) == j,end))./sum(VAL(:,end));  
        tTheta = [tRateSum+tT.*tRate,tRateSum+tRate-tT.*tRate].*pi.*2;
        tR = [tT.*0+i,tT.*0+i+1];
        if i == 1
            fill(cos(tTheta).*tR,sin(tTheta).*tR,CList(j,:),'EdgeColor',[1,1,1],'LineWidth',1)
        else
            tCN = VAL(find(VAL(:,i) == j,1),1);
            fill(cos(tTheta).*tR,sin(tTheta).*tR,...
                CList(tCN,:).*0.8^(i-1)+[1,1,1].*(1-0.8^(i-1)),'EdgeColor',[1,1,1],'LineWidth',1)
        end
        
        rotation = (tRateSum+tRate/2)*360;
        if tRate > TextThreshold
        if rotation>90&&rotation<270
            rotation=rotation+180;
            text(cos((tRateSum+tRate/2).*pi.*2)*i,sin((tRateSum+tRate/2).*pi.*2)*i,NameCell{i}(j,:)+" ",FontProp{:},...
                'Rotation',rotation,'HorizontalAlignment','right')
        else
            text(cos((tRateSum+tRate/2).*pi.*2)*i,sin((tRateSum+tRate/2).*pi.*2)*i," "+NameCell{i}(j,:),FontProp{:},...
                'Rotation',rotation)
        end
        end
        tRateSum = tRateSum+tRate;
    end
end
% 绘制最外圈饼状图
tRateSum = 0;
tNameCell = Table.(NameList{end-1});
for j = 1:size(VAL,1)
    tRate = VAL(j,end)./sum(VAL(:,end)); 
    tTheta = [tRateSum+tT.*tRate,tRateSum+tRate-tT.*tRate].*pi.*2;
    tR = [tT.*0+size(VAL,2),tT.*0+size(VAL,2)+1];
    tCN = VAL(j,1);
    fill(cos(tTheta).*tR,sin(tTheta).*tR,CList(tCN,:).*0.8^(size(VAL,2)-1)+...
        [1,1,1].*(1-0.8^(size(VAL,2)-1)),'EdgeColor',[1,1,1],'LineWidth',1)
    rotation = (tRateSum+tRate/2)*360;
    if tRate > TextThreshold
    if rotation>90&&rotation<270
        rotation=rotation+180;
        text(cos((tRateSum+tRate/2).*pi.*2)*size(VAL,2),sin((tRateSum+tRate/2).*pi.*2)*size(VAL,2),tNameCell(IDX(j),:)+" ",FontProp{:},...
            'Rotation',rotation,'HorizontalAlignment','right')
    else
        text(cos((tRateSum+tRate/2).*pi.*2)*size(VAL,2),sin((tRateSum+tRate/2).*pi.*2)*size(VAL,2)," "+tNameCell(IDX(j),:),FontProp{:},...
            'Rotation',rotation)
    end
    end
    tRateSum = tRateSum+tRate;
end















