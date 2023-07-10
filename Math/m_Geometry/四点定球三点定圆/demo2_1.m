% 随便找三个点，画出点的图像
pnt=[1 2;3 4;7 5];
scatter(pnt(:,1),pnt(:,2),'filled')
hold on

% 获得隐函数并画圆
[Func,~,~]=getCircle(pnt(:,1),pnt(:,2));
fimplicit(Func,[-0 15 -10 6],'LineWidth',2,'Color',[114,146,184]./255)

% 修饰一下，这句可删掉
decoAx()