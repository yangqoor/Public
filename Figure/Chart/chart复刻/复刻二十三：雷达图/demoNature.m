rng(1)
figure('Position',[600,200,600,600]);

Data1 = rand([2,10]);
RC = radarChart(Data1);


RC.RLim = [0,1];         % 数据范围设置为 0,1            Set the data range to be between 0 and 1
RC.RTick = [0,.5,1];     % 半径刻度 0,.5,1              Set radius ticks at 0, 0.5, and 1
RC.RRange = [.1,1];      % 背景所占的比例范围            Set the range for the background (0.1 to 1)
RC.Rotation = pi/2;      % 初始角度                     Set the initial angle
RC.ThetaDir = 'reverse'; % 标签排布方向(逆时针还是顺时针) Set the direction of the label arrangement

% 设置变量名
RC.ClassName = {'Stalk-like','Tip-like'};
RC.PropName = num2cell('A':'J'); 
% RC.PropName = {'A','B','C','D','E','F','G','H','I','J'}
RC.CList = [151,125,154; 179,97,97]./255;


RC = RC.draw();

% 设置一下背景线条粗细等属性
RC.setPropLabel('FontSize',21,'FontName','Times New Roman');
RC.setRTick('LineWidth',2);
RC.setRLabel('Color','none');
RC.setBkg('EdgeColor','none');
RC.setThetaTick('LineWidth',2);
RC.setType('Both')

RC.setPatchN(1, 'LineWidth',5, 'MarkerSize',8);
RC.setPatchN(2, 'LineWidth',5, 'MarkerSize',8);

RC = RC.legend();
RC.setLegend('FontSize',21, 'FontName','Times New Roman');