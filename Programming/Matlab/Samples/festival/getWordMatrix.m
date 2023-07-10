function wordMatrix=getWordMatrix(char)
fig=figure('units','pixels',...
        'position',[20 20 160 160],...
        'Numbertitle','off',...
        'Color',[1 1 1],...
        'resize','off',...
        'visible','off',...
         'menubar','none');

ax=axes('Units','pixels',...
        'parent',fig,...  
        'Color',[1 1 1],...
        'Position',[0 0 160 160],...
        'XLim',[0 16],...
        'YLim',[0 16],...
        'XColor',[1 1 1],...
        'YColor',[1 1 1]);
hold(ax,'on')
%,'FontWeight','bold
text(ax,8,8.5,char,'HorizontalAlignment','center','FontSize',120)
if 1
saveas(fig,['.\',char,'.png']);

pic=imread(['.\',char,'.png']);
delete(['.\',char,'.png'])
delete(ax)
close

[rowMax,colMax,~]=size(pic);
picData=pic(:,:,1);
picData(picData<125)=1;
picData(picData>=125)=0;

wordMatrix=zeros(25,25);
for i=1:25
    rowLim=round([i-1,i]./25.*rowMax);
    rowLim(rowLim==0)=1;
    
    for j=1:25
        colLim=round([j-1,j]./25.*colMax);
        colLim(colLim==0)=1;
        wordMatrix(i,j)=sum(sum(picData(rowLim(1):rowLim(2),colLim(1):colLim(2))));
    end
end
wordMatrix(wordMatrix<10)=0;
wordMatrix=wordMatrix';
wordMatrix=wordMatrix(:,end:-1:1);
wordMatrix(wordMatrix~=0)=1;

end
end
