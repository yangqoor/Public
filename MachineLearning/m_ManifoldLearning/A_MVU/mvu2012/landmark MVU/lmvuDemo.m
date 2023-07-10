N=2000; % Number of points
fact=3; % Length of roll

figure;
fprintf('landmark-mvu Demo\n');
fprintf('(assumes that CSDP is installed)\n');
% Generate Swiss roll 
colormap jet;
tt = (fact*pi/2)*(1+2*rand(1,N));  height = fact*7*rand(1,N);
X = [tt.*cos(tt); height; tt.*sin(tt)];
M=min(min(abs(X)));
color=tt;

% centralizing input
X=X-repmat(mean(X,2),1,N);


% Display Input
fprintf('Display Input ... \n');
hin=scatter3(X(1,:),X(2,:),X(3,:),50,color,'filled');
set(hin,'MarkerEdgeColor',[0.5 0.5 0.5]);
axis equal;
box on;
view([    0.9194   -0.3934   -0.0000   -0.2630
          0.0511    0.1193    0.9915   -0.5809
          0.3901    0.9116   -0.1297    5.5152
          0         0         0         1.0000]);
set(gca,'XTick',[],'YTick',[],'ZTick',[])
fprintf('Input consists of %i data points sampled form a swiss roll.\n',N);          
drawnow;          
% Run lmvu
fprintf('Unfold Input ... \n');
[Y,Details]=lmvu(distance(X),20);


% Display Output
fprintf('Display Output ... \n');
figure;
hout=scatter(Y(1,:),Y(2,:),50,color,'filled');
set(hout,'MarkerEdgeColor',[0.5 0.5 0.5]);
axis equal;
box on;
set(gca,'XTick',[],'YTick',[],'ZTick',[]);
drawnow;          

% Write a cheesy line
fprintf('Done! (%2.2f Minutes)\n',Details.time/60);
