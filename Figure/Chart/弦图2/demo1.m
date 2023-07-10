% demo 1 随机数据
rng(1)


% 生成随机200x200对称0-1矩阵
Data=rand(200,200)>.992;
sum(sum(Data))
Data=(Data+Data')>0;
% 生成200x1随机分类编号
Class=randi([1,5],[200,1]);

for i=1:200
    partName{i}=[num2str(Class(i)),'-',num2str(i)];
end
className={'AAAAA','BBBBB','CCCCC','DDDDD','EEEEE'};

% CC=circosChart(Data,Class);
CC=circosChart(Data,Class,'PartName',partName,'ClassName',className);
CC=CC.draw();

CC.setPartLabel('Color',[0,0,.8],'FontName','Cambria')
CC.setClassLabel('Color',[.8,0,0],'FontName','Cambria','FontSize',25)