treeList=readcell('data.xlsx');
treeList=treeList(:,1:3);

CT=circleTree3(treeList);
CT=CT.draw();

% CT.setLable2('Visible','on');

% CT.setColorN(2,[.8,0,0]);

