% 需要mapping toolbox
[Z,R]=readgeoraster('n39_w106_3arc_v2.dt1','OutputType','double');

key.GTModelTypeGeoKey=2;
key.GTRasterTypeGeoKey=2;
key.GeographicTypeGeoKey=4326;

filename='southboulder.tif';
% 假设NaN值被存为-999
Z(Z<2100)=-999;

% 将其数值设置为非NaN值最小值-1/10的非NaN值数值范围
% 这样colorbar灰色部分的长度就会是不是灰色的部分长度的1/10；
Z(Z==-999)=nan;minVal=min(min(Z));
Z(isnan(Z))=min(min(Z))-(max(max(Z))-min(min(Z)))./10;
geotiffwrite(filename,Z,R,'GeoKeyDirectoryTag',key)

usamap([39 40],[-106 -105])
g=geoshow(filename,'DisplayType','mesh');

% 往colormap前面续加上一段等长的灰色
CList=nclCM(15,100);
CList=[(CList(:,1).*0+1)*[240,240,240]./255;CList];
colormap(CList)
cbHdl=colorbar();

% 调整配色范围
setPivot(minVal)

% 调整colorbar标签文字
cbHdl.TickLabels{cbHdl.Ticks<minVal}='';
cbHdl.TickLabels{1}='NaN';









