rng(2)

% 随机生成数据及分类
Data=rand(1,50).*linspace(10,100,50);
Class=randi([1,5],[50,1]); 

CT=rectTree(Data,Class);
CT=CT.draw();


% CT.setColor(5,[.1,.1,.7]);
% CT.setPatch('EdgeColor',[1,1,1])
% CT.setFont('FontName','Cambria','FontSize',16)
% CT.setLabel('FontName','Cambria','FontSize',25,'Color',[0,0,.8])