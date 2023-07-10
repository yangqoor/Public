f1=@(x,y,z)x.^2+y.^2-z.^2;
f2=@(x,y,z)x.^2+1.5*y.^2+z.^2-12;

% 绘制曲面
fimplicit3(f1,'EdgeColor','none','FaceAlpha',0.5,'FaceColor',[82,124,179]./255)
hold on;
fimplicit3(f2,'EdgeColor','none','FaceAlpha',0.5,'FaceColor',[169,64,71]./255)

[X,Y,Z]=meshgrid(-5:.1:5);
[nX,nY,nZ]=isocurve3(X,Y,Z,f1,f2);
line(nX(:),nY(:),nZ(:),'LineWidth',2,'Color',[0,0,0]); 