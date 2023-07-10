function demo
oriPic=imread('test.jpg');
colorNum=8;


Rchannel=oriPic(:,:,1);
Gchannel=oriPic(:,:,2);
Bchannel=oriPic(:,:,3);
RGBList=double([Rchannel(:),Gchannel(:),Bchannel(:)]);
[index,C]=kmeans(RGBList,colorNum,'Distance','sqeuclidean','MaxIter',1000,'Display','iter');

hold on
grid on
STR=[];
C=round(C);
for i=1:colorNum
    scatter3(RGBList(index==i,1),RGBList(index==i,2),RGBList(index==i,3),...
        'filled','CData',C(i,:)./255);
    STR{i}=[num2str(C(i,1)),' ',num2str(C(i,2)),' ',num2str(C(i,3))];
end
legend(STR,'Color',[0.9412    0.9412    0.9412],'FontName','Cambria','LineWidth',0.8,'FontSize',11)

ax=gca;
ax.GridLineStyle='--';
ax.LineWidth = 1.2;

ax.XLabel.String='R channel';
ax.XLabel.FontSize=13;
ax.XLabel.FontName='Cambria';

ax.YLabel.String='G channel';
ax.YLabel.FontSize=13;
ax.YLabel.FontName='Cambria';

ax.ZLabel.String='B channel';
ax.ZLabel.FontSize=13;
ax.ZLabel.FontName='Cambria';

end