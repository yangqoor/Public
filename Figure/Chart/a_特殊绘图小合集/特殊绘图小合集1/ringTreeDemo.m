% ringTreeDemo

% 20个变量
figure(1)
rng('default')
X=rand(20,3);
ringTree(X);

% 50个变量
figure(2)
X=rand(50,3);
ringTree(X);

% 随便定义变量名
Name{50}=[];
for i=1:50
    Name{i}=['slan',num2str(i)];
end
figure(3)
X=rand(50,3);
ringTree(X,Name);


% 修饰文字和树
figure(4)
X=rand(50,3);
[treeHdl,txtHdl]=ringTree(X);
for i=1:length(treeHdl)
    treeHdl(i).Color=[0,0,.8];
end
for i=1:length(txtHdl)
    txtHdl(i).FontName='Cambria';
    txtHdl(i).Color=[.8,0,0];
end