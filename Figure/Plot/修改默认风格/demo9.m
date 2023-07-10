% 仅此文件至少R2021a
figure('Position',[120,120,800,600])
tl=tiledlayout(2,2);
tl.TileSpacing='compact';
tl.Padding='tight';


% 坐标区域块 1
nexttile
t=0.01:0.01:3*pi;
plot(t,cos(t)./(1+t))
hold on
plot(t,sin(t)./(1+t))
plot(t,cos(t+pi/2)./(1+t+pi/2))
plot(t,cos(t+pi)./(1+t+pi))
legend

% 坐标区域块 2
nexttile
axis([0,50,0,50,-10,10])
xticks(0:10:50)
yticks(0:10:50)
zticks(-10:5:10)
hold on
surf(peaks)
set(gca,'Projection','perspective')
view(-37,42) 

% 坐标区域块 3
nexttile
t=linspace(pi/100,4*pi,500);
y1=cos(t).^2;
y2=sin(t).^2./t;
hold on
area(y1)
area(y2)

% 坐标区域块 4
nexttile
y=[2 2 3; 2 5 6; 2 8 9; 2 11 12];
bar(y)