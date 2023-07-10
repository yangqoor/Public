Data=readcell('seqlogo_DNA.txt');
Data=Data(2:2:end,1);
Data=reshape([Data{:}],[],length(Data))';

figure()
seqLogo(Data)

figure()
seqLogo(Data,'Method','Prob')   
