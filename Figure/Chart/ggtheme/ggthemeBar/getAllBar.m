nSet={'flat','flat_dark','camouflage','chalk','copper','dust','earth','fresh',...
    'grape','grass','greyscale','light','lilac','pale','sea','sky','solarized'};

for i=1:length(nSet)
    figure(i)
    y=[6 3 4 2 1;12 6 3 2 1;9 5 2 2 2;7 3 1 1 0;5 2 2 1 1;2 1 1 0 1;];
    bar(y)
    legend('class1','class2','class3','class4','class5')
    ggThemeBar(gca,nSet{i});
    exportgraphics(gca,[nSet{i},'.png'])
end
close all