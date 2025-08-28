
X1=[2,2.3,3.7,4.1,5.1,6,7,8];
X2=[1,1.7,1.9,3.8,4.7,5,7,8];
Label1={'A1','A2','A3','A4','A5','A6','A7','A8'};
Label2={'B1','B2','B3','B4','B5','B6','B7','B8'};

fig=figure();
ax1=axes('Parent',fig);
% defualtAxes()
hold on;axis tight;box off
ax1.Position=[.1,.08,1/2-.1,.9]; 
ax1.YDir='reverse';
ax1.XDir='reverse';
ax1.YTickLabel=Label1;
barh(ax1,X1,'FaceColor',[0,.447,.741])

ax2=axes('Parent',fig);hold on;axis tight
% defualtAxes()
hold on;axis tight;box off
ax2.Position=[1/2,.08,1/2-.1,.9]; 
ax2.YDir='reverse';
ax2.YAxisLocation='right';
ax2.YTickLabel=Label2;
barh(ax2,X2,'FaceColor',[.85,.325,.098])