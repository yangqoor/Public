t=0:0.6:3*pi;

nSet={'flat','flat_dark','camouflage','chalk','copper','dust','earth','fresh',...
    'grape','grass','greyscale','light','lilac','pale','sea','sky','solarized'};
for i=1:length(nSet)
    figure(i)
    plot(t,sin(t).*1.2,'LineWidth',2,'Marker','o')
    hold on
    plot(t,cos(t./2),'LineWidth',2,'Marker','s')
    plot(t,t,'LineWidth',2,'Marker','^')
    
    lgd=legend(' y=1.2sin(t)',' y=cos(t/2)',' y=t');
    lgd.Location='best';
    title(lgd,'Func')
    ggThemePlot(gca,nSet{i})
    exportgraphics(gca,[nSet{i},'.png'])
end
close all