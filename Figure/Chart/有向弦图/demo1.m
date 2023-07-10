% demo 1
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : slandarer

dataMat=randi([0,8],[6,6]);

BCC=biChordChart(dataMat,'Arrow','on');
BCC=BCC.draw();

% BCC=biChordChart(dataMat,'Arrow','on','CData',[]);
% BCC=BCC.draw();
% 
% BCC=biChordChart(dataMat,'Arrow','on','CData',bone(9));
% BCC=BCC.draw();

% ColorList=[127,91,93;153,66,83;95,127,95;9,14,10;78,70,83;0,0,0]./255;
% BCC=biChordChart(dataMat,'Arrow','on','CData',ColorList);
% BCC=BCC.draw();


% ColorList=lines(6);
% for i=1:6
%     BCC.setSquareN(i,'FaceColor',ColorList(i,:))
%     BCC.setChordN(i,'FaceColor',ColorList(i,:))
% end

% ----------------------------------------------------------
% 标记最大值弦
% [m,n]=find(dataMat==max(max(dataMat)));
% for i=1:length(m)
%     BCC.setChordMN(m(i),n(i),'EdgeColor',[.8,0,0],'LineWidth',2)
% end

