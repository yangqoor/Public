% 3D填充折线

% 获取数据
[X,Y]=demoDataN();

% 设置颜色
colorList=[0.2549    0.2784    0.4196
    0.4039    0.3294    0.4706
    0.6196    0.3882    0.4549
    0.7765    0.4824    0.4353
    0.8706    0.6078    0.4431
    0.9373    0.7373    0.5098
    0.9843    0.8745    0.6353];

hold on
% 绘制填充
for i=1:size(Y,1)
    fill3([X(1),X,X(end)],[i,X.*0+i,i],[min(Y(i,:)),Y(i,:),min(Y(i,:))],...
        colorList(i,:),'FaceAlpha',.7,'EdgeColor','none')
end

% 绘制折线图
for i=1:size(Y,1)
    plot3(X,X.*0+i,Y(i,:),'LineWidth',1,'Color',colorList(i,:))
end

% 坐标区域修饰
defualtAxes();
set(gca,'Projection','perspective','GridAlpha',.05)
view(39,45)