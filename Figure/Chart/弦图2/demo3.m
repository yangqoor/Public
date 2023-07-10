% demo3 随机数据+修饰
rng(1)


% 生成随机200x200对称0-1矩阵
Data=rand(200,200)>.992;
sum(sum(Data))
Data=(Data+Data')>0;
% 生成200x1随机分类编号
Class=randi([1,5],[200,1]);

colorList=[78 101 155;
          138 140 191;
          184 168 207;
          231 188 198;
          253 207 158]./255;

CC=circosChart(Data,Class);%,'ColorOrder',colorList);
CC=CC.draw(); 


% CC.setLine('LineWidth',5)
CC.setColor(1:5,colorList)
