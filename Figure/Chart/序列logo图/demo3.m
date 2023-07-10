Data=readcell('seqlogo_DNA.txt');
Data=Data(2:2:end,1);
Data=reshape([Data{:}],[],length(Data))';

Color={'C',[205,255,101]./255,'A',[104,101,255]./255,'TU',[164,230,101]./255,'G',[104,203,254]./255};
% Color={'C',[127,91,93]./255,'A',[187,128,110]./255,'TU',[197,173,143]./255,'G',[59,71,111]./255};

figure()
seqLogo(Data,'Color',Color)

figure()
seqLogo(Data,'Method','Prob','Color',Color)    
