function drawCaption(string)
if nargin<1
    string='»¶Ó­¹Ø×¢ÎÒµÄCSDN';
end
string=[string,' '];
CaptionMat=zeros(25*length(string),25);
for i=1:length(string)
    CaptionMat(25*(i-1)+1:25*i,:)=getWordMatrix(string(i));
end
CaptionMat=[CaptionMat;CaptionMat;CaptionMat];

fig=figure('units','pixels',...
        'position',[100 300 1000 250],...
        'Numbertitle','off',...
        'Color',[0 0 0],...
        'resize','off',...
         'menubar','none');

ax=axes('Units','pixels',...
        'parent',fig,...  
        'Color',[0 0 0],...
        'Position',[0 0 1000 250],...
        'XLim',[0 140],...
        'YLim',[0-5 25+5],...
        'XColor',[0 0 0],...
        'YColor',[0 0 0]);
hold(ax,'on')
[xSet,ySet]=find(CaptionMat~=0);


offset=0;
drawHdl=scatter(xSet+140-offset,ySet,28,'s','filled');

fps=25;
DCtimer=timer('ExecutionMode', 'FixedRate', 'Period',1/fps, 'TimerFcn', @refreshWord);
start(DCtimer)
    function refreshWord(~,~)
        offset=offset+1;
        if mod(offset,length(string)*50)==0
            offset=offset-length(string)*25;
        end
        set(drawHdl,'XData',xSet+140-offset)  
    end
end
