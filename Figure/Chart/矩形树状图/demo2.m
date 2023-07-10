rng(2)

Data=[1;3;2;6;3;7;2;5;6;8;9;2;4;4;6;1;5;9;1;2;6;9;4;1;4];
Class=randi([1,5],[25,1]); 
for i=1:length(Data)
    Name{i}=['p',num2str(i)];
end
ClassName={'AAAAA','BBBBB','CCCCC','DDDDD','EEEEE'};

CT=rectTree(Data,Class,'Name',Name,'ClassName',ClassName);
CT=CT.draw();
