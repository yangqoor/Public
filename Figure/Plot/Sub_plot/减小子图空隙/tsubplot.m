function ax=tsubplot(rows,cols,ind,type)
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
if nargin<4,type='tight';end
sz=[rows,cols];
ratio1=[0,0,1,1];
switch type
    case 'tight'
        ratio1=[0,0,1,1];
        % ratio2=[0.031 0.054 0.9619 0.9254];
    case 'compact'
        ratio1=[0.034 0.0127 0.9256 0.9704];
        % ratio2=[0.065 0.0667 0.8875 0.8958];
    case 'loose'
        ratio1=[0.099 0.056 0.8131 0.8896];
        % ratio2=[0.13 0.11 0.775 0.815];
end
k=1;
posList=zeros(sz(1)*sz(2),4);
for i=1:sz(1)
    for j=1:sz(2)
        tpos=[(j-1)/sz(2),(sz(1)-i)/sz(1),1/sz(2),1/sz(1)];
        posList(k,:)=[tpos(1)+tpos(3).*ratio1(1),tpos(2)+tpos(4).*ratio1(2),...
                      tpos(3).*ratio1(3),tpos(4).*ratio1(4)];
        k=k+1;
    end
end
posSet=posList(ind(:),:);
xmin=min(posSet(:,1));
ymin=min(posSet(:,2));
xmax=max(posSet(:,1)+posSet(:,3));
ymax=max(posSet(:,2)+posSet(:,4));
ax=axes('Parent',gcf,'LooseInset',[0,0,0,0],...
    'OuterPosition',[xmin,ymin,xmax-xmin,ymax-ymin]);
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
end