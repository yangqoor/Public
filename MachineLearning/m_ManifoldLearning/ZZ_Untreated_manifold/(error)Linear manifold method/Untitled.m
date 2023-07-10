clear all
ppm = [400 400 400 400];        % points per mixture
centers = [7.5 7.5; 7.5 12.5; 12.5 7.5; 12.5 12.5];
stdev = 1;
[data2,labels]=makegaussmixnd(centers,stdev,ppm);
plotcol (data2, ppm, 'rgbk');
