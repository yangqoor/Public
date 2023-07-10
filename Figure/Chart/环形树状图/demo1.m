
treeList={[],[]};
k=1;
classNameSet={'A','B','C','D','E','F'};
classNumSet=[20,20,20,25,30,35];
for i=1:6
    for j=1:classNumSet(i)
        treeList{k,1}=['CLASS ',classNameSet{i}];
        treeList{k,2}=[classNameSet{i},num2str(j)];
        k=k+1;
    end
end

CT=circleTree2(treeList);
CT=CT.draw();

% CT.setColorN(2,[.8,0,0]);
% CT.setLable1('FontSize',16,'Color',[0,0,.8]);
% CT.setLable2('FontSize',13,'Color',[0,.6,.8]);

% for i=1:6
% CT.setColorN(i,[.8,.8,.8]);
% end
