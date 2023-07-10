% Some sample data with noise:
x = 10*rand(300,1)-5;
noise = 2*randn(size(x));
y = x.^2+noise;

% A theoretical perfect x^2 line:
x_theoretical = linspace(min(x),max(x),50);
y_theoretical = x_theoretical.^2;

% Plot the data:
figure
plot(x_theoretical,y_theoretical,'k-')
hold on
scatter(x,y,25,noise,'filled')

CM=[0.0941    0.1098    0.2627
    0.0431    0.3725    0.7451
    0.4588    0.6667    0.7451
    0.9451    0.9255    0.9235
    0.8157    0.5451    0.4510
    0.6510    0.1353    0.1431
    0.2353    0.0353    0.0706];
CMX=linspace(0,1,size(CM,1));
CMXX=linspace(0,1,256)';
CM=[interp1(CMX,CM(:,1),CMXX,'pchip'), ...
    interp1(CMX,CM(:,2),CMXX,'pchip'), ...
    interp1(CMX,CM(:,3),CMXX,'pchip')];
colormap(CM)
cb=colorbar;
ylabel(cb,'error relative to theory')
box off
axis tight 
grid on

% 调整颜色图中点位置
setPivot(0)


defualtAxes