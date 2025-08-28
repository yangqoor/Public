function areah(varargin)
% @author : slandarer
if isa(varargin{1},'matlab.graphics.axis.Axes')
    ax=varargin{1};varargin(1)=[];
else
    ax=gca;
end
hold on
X=varargin{1};Y=varargin{2};
XList=linspace(min(X(:)),max(X(:)),1000);
YList=linspace(min(Y(:)),max(Y(:)),1000);
[~,YMesh]=meshgrid(XList,YList);
YY=interp1(X(:),Y(:),XList);

coe.Color=lines(ax.ColorOrderIndex);
coe.LineWidth=2;
for i=3:2:length(varargin)
    coe.(varargin{i})=varargin{i+1};
end
CMesh=zeros(1000,1000,3);
CMesh(:,:,1)=ones(1000,1000).*coe.Color(1);
CMesh(:,:,2)=ones(1000,1000).*coe.Color(2);
CMesh(:,:,3)=ones(1000,1000).*coe.Color(3);
AMesh=linspace(0,.5,1000)'.*ones(1,1000);
AMesh(YMesh>YY)=0;

image(ax,[min(X(:)),max(X(:))],[min(Y(:)),max(Y(:))],CMesh,'AlphaData',AMesh)
plot(ax,X(:),Y(:),'Color',coe.Color,'LineWidth',coe.LineWidth)
ax.ColorOrderIndex=ax.ColorOrderIndex+1;
end