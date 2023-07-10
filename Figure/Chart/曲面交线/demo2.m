% 显函数与隐函数绘制曲面交线
f1=@(x,y,z)5-2.*x-1.5.*y-z;
f2=@(x,y,z)x.^2+y.^2+z.^2-12;

[X,Y]=meshgrid(-3:.1:4);
Z1=5-2.*X-1.5.*Y;

% 绘制曲面
surf(X,Y,Z1,'EdgeColor','none','FaceAlpha',0.5,'FaceColor',[82,124,179]./255)
hold on;
fimplicit3(f2,'EdgeColor','none','FaceAlpha',0.5,'FaceColor',[169,64,71]./255)

% 通过切片contour函数获取0等势面
[CX,CY,CZ]=meshgrid(-3:.1:4);
CV=f1(CX,CY,CZ)-f2(CX,CY,CZ);
S=contourslice(CX,CY,CZ,CV,X,Y,Z1,[0,0]);
S.EdgeColor=[0,0,0];
S.LineWidth=2; 