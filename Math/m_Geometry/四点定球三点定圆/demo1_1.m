% 随便找四个点，画出点的图像
pnt=[0,0,1;1,1,6;1,3,4;9,6,11];
scatter3(pnt(:,1),pnt(:,2),pnt(:,3),'filled')
hold on

% 获取匿名函数并用fimplicit3绘制三维隐函数
[Func,~,~]=getBall(pnt(:,1),pnt(:,2),pnt(:,3));
fimplicit3(Func,[-30,30],'MeshDensity',40,'EdgeColor','interp','FaceAlpha',.3)

% 修饰一下，这句可删掉
decoAx()