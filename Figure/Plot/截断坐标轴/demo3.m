y=[120 91 105 143.5 131 150 179 203 226 249 281.5,800,820,800];
b=bar(y);
b(1).ShowBaseLine='off';
box off

set(gca,'Position',[0.06,0.06,.92,.92]);
% prettyAxes().gbase()

truncAxis('Y',[300,700])
ax=gca;
ax.Children(1).ShowBaseLine='off';


legend