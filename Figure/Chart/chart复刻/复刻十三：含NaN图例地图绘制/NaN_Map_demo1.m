% 需要mapping toolbox
[Z,R]=readgeoraster('n39_w106_3arc_v2.dt1','OutputType','double');

key.GTModelTypeGeoKey=2;
key.GTRasterTypeGeoKey=2;
key.GeographicTypeGeoKey=4326;

filename='southboulder.tif';
% 设置NaN值
Z(Z<2100)=nan;
geotiffwrite(filename,Z,R,'GeoKeyDirectoryTag',key)


usamap([39 40],[-106 -105])
g=geoshow(filename,'DisplayType','mesh');

% 190 300 363
colormap(nclCM(15,100))
cbHdl=colorbar();
% 修改colorbar位置
tPosition=cbHdl.Position;
cbHdl.Position(1)=cbHdl.Position(1)+tPosition(3).*1.5;
cbHdl.Position(2)=cbHdl.Position(2)+tPosition(4)./10;
cbHdl.Position(4)=cbHdl.Position(4)-tPosition(4)./10;

% 绘制nan图例
nanHdl=fill([0,1,1,0]-1000,[0,0,1,1]-1000,[240,240,240]./255,...
    'EdgeColor','none','EdgeColor',[160,160,160]./255,'LineWidth',1.2,...
    'DisplayName',' NaN');
lgdHdl=legend(nanHdl);
lgdHdl.Box='off';
lgdHdl.ItemTokenSize=[16,16];
lgdHdl.Position(1)=tPosition(1)+tPosition(3).*1.3;
lgdHdl.Position(2)=tPosition(2);
