% Copyright ? 2009, Xin Zhao
% All rights reserved.
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
function heartSudoku2
sizeTheta=30;
sizeFai=40;
theta=linspace(0,pi,sizeTheta)';
nudge=0.0001; % used to avoid the operlapping
fai=linspace(0+nudge,pi/2-nudge,round(sizeFai/4));
a=9/4;
b=9/80;
A=1+(a-1)*(sin(theta).^2)*(sin(fai).^2);
B=(sin(theta).^2.*cos(theta).^3) * (1+(b-1)*(sin(fai).^2));
rou = zeros(size(A));
for iLoop=1:numel(A)
    curA=A(iLoop);
    curB=B(iLoop);
    % this is the polar coordinates version of the sextic equation found on
    % http://mathworld.wolfram.com/HeartSurface.html
    polyFactors=[curA^3,-curB,-3*curA^2,0,3*curA,0,-1];
    solutions=roots(polyFactors);    
    realRou=real(solutions(abs(imag(solutions))<1e-9));
    rou(iLoop)=realRou(realRou>0);    
end

% x,y,z for the quater of whole heart
x=rou.*(sin(theta)*cos(fai));
y=rou.*(sin(theta)*sin(fai));
z=rou.*(cos(theta)*ones(size(fai)));

% x,y,z for the whole heart
cordX=[x,-fliplr(x),-x,fliplr(x)];
cordY=[y,fliplr(y),-y,-fliplr(y)];
cordZ=[z,fliplr(z),z,fliplr(z)];

heartSudokuFig=figure('units','pixels',...
    'position',[200 50 630 630],...
    'Numbertitle','off',...
    'menubar','none',...
    'resize','off',...
    'name','heart sudoku',...
    'color',[0.99 0.99 0.99]);
for i=1:3
    for j=1:3
      heartSudokuAxes(i,j)=axes('Units','pixels',...
      'parent',heartSudokuFig,...
      'Position',[(i-1)*210-25,(j-1)*210-25-10,210+50,210+50],...
      'Color',[0.99 0.99 0.99],...
      'Box','on', ...
      'XLim',[-1.28,1.28],'YLim',[-1.28,1.28],'ZLim',[-1.28,1.28],...
      'XColor','none','YColor','none','ZColor','none');
      hold(heartSudokuAxes(i,j),'on')
      camtarget([0, 0, 0]);
      view(30,20);
      
    end
end
markerColor=[248 150 170]./255;
lineColor=[248 150 170]./255;
lineWidth=0.8;
%[1 1]=====================================================================
for iLoop=1:3:size(cordX,1)
    plot3(heartSudokuAxes(1,1),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'Marker','.','MarkerSize',3.5,'MarkerEdgeColor',markerColor,'LineStyle','none');
    plot3(heartSudokuAxes(1,1),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
for iLoop=1:4:size(cordX,2)
    plot3(heartSudokuAxes(1,1),cordX(:,iLoop),cordY(:,iLoop),cordZ(:,iLoop),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
%[1 2]=====================================================================
for iLoop=1:3:size(cordX,1)
    plot3(heartSudokuAxes(1,2),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'Marker','.','MarkerSize',3.5,'MarkerEdgeColor',markerColor,'LineStyle','none');
    plot3(heartSudokuAxes(1,2),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),'color',...
        lineColor,'LineStyle','-','LineWidth',lineWidth);
end
for iLoop=1:size(cordX,2)
    plot3(heartSudokuAxes(1,2),cordX(:,iLoop),cordY(:,iLoop),cordZ(:,iLoop),'color',...
        lineColor,'LineStyle','-','LineWidth',lineWidth);
end
%[1 3]=====================================================================
for iLoop=1:size(cordX,1)
    plot3(heartSudokuAxes(1,3),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'Marker','.','MarkerSize',3.5,'MarkerEdgeColor',markerColor,'LineStyle','none');
    plot3(heartSudokuAxes(1,3),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
for iLoop=1:size(cordX,2)
    plot3(heartSudokuAxes(1,3),cordX(:,iLoop),cordY(:,iLoop),cordZ(:,iLoop),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
%[2 1]=====================================================================
for iLoop=[2 8 15 25]
    plot3(heartSudokuAxes(2,1),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'Marker','.','MarkerSize',3.5,'MarkerEdgeColor',markerColor,'LineStyle','none');
    plot3(heartSudokuAxes(2,1),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
for iLoop=1:2:size(cordX,2)
    plot3(heartSudokuAxes(2,1),cordX(:,iLoop),cordY(:,iLoop),cordZ(:,iLoop),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
%[2 2]=====================================================================
for iLoop=1:2:size(cordX,1)
    plot3(heartSudokuAxes(2,2),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'Marker','.','MarkerSize',3.5,'MarkerEdgeColor',markerColor,'LineStyle','none');
    plot3(heartSudokuAxes(2,2),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
for iLoop=1:2:size(cordX,2)
    plot3(heartSudokuAxes(2,2),cordX(:,iLoop),cordY(:,iLoop),cordZ(:,iLoop),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
%[2 3]=====================================================================
for iLoop=[1 3 5 9 20 25 27]
    plot3(heartSudokuAxes(2,3),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'Marker','.','MarkerSize',3.5,'MarkerEdgeColor',markerColor,'LineStyle','none');
    plot3(heartSudokuAxes(2,3),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
for iLoop=1:size(cordX,2)
    plot3(heartSudokuAxes(2,3),cordX(:,iLoop),cordY(:,iLoop),cordZ(:,iLoop),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
%[3 1]=====================================================================
for iLoop=[2 6 8 15 ]
    plot3(heartSudokuAxes(3,1),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'Marker','.','MarkerSize',3.5,'MarkerEdgeColor',markerColor,'LineStyle','none');
    plot3(heartSudokuAxes(3,1),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
for iLoop=[8 9 18 21 30 32 35 40]
    plot3(heartSudokuAxes(3,1),cordX(:,iLoop),cordY(:,iLoop),cordZ(:,iLoop),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
%[3 2]=====================================================================
for iLoop=[8 12 15 18 23 25]
    plot3(heartSudokuAxes(3,2),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'Marker','.','MarkerSize',3.5,'MarkerEdgeColor',markerColor,'LineStyle','none');
    plot3(heartSudokuAxes(3,2),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
for iLoop=[8 9 18 21 25 28 30 32 35 40]
    plot3(heartSudokuAxes(3,2),cordX(:,iLoop),cordY(:,iLoop),cordZ(:,iLoop),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
%[3 3]=====================================================================
for iLoop=[8 18 25]
    plot3(heartSudokuAxes(3,3),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'Marker','.','MarkerSize',3.5,'MarkerEdgeColor',markerColor,'LineStyle','none');
    plot3(heartSudokuAxes(3,3),cordX(iLoop,:),cordY(iLoop,:),cordZ(iLoop,:),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
for iLoop=1:3:40
    plot3(heartSudokuAxes(3,3),cordX(:,iLoop),cordY(:,iLoop),cordZ(:,iLoop),...
        'color',lineColor,'LineStyle','-','LineWidth',lineWidth);
end
end
