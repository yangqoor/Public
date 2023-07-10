Data=readcell('seqlogo_protein_2.txt'); 
Data=Data(2:2:end,1);
Data=reshape([Data{:}],[],length(Data))';

figure()
seqLogo(Data,'Type','PR')

figure()
seqLogo(Data,'Type','PR','Method','Prob')   