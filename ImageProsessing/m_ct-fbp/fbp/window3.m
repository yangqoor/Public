function pic1 = window3(mi,ma,roi,pic);
%function pic1 = window3(mi,ma,roi,pic);
% displays image pic with coordinates given by roi
% roi = [xmin xmax ymin ymax]
x = [roi(1), roi(2)]; y = [roi(3), roi(4)];
colors = 128; co = colors-1;
pic1 = pic - mi*ones(size(pic));
pic1 = (co/(ma-mi))*pic1;
% P = (pic1 >= 0);
% pic1 = pic1.*P;
% P = (pic1 <= co);
% pic1 = pic1.*P + co*(ones(size(pic1)) - P);
colormap(gray(colors));
image(x,fliplr(y),flipud(pic1));
axis('square');