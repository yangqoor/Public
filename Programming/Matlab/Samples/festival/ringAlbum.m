function ringAlbum
BlockNum=[7,11];
R=[300,670;
   670,1090];
lineColor=[0.98,0.98,0.98];
lineWidth=2;

path='.\';%文件夹名称
files=dir(fullfile(path,'*.jpg')); 
picNum=size(files,1);

%遍历路径下每一幅图像
for i=1:picNum
   fileName = strcat(path,files(i).name); 
   img = imread(fileName);
   imgSet.(['p',num2str(i)])=img;
end

fig=figure('units','pixels',...
        'position',[20 60 560 560],...
        'Color',[1 1 1]);
ax=axes('Units','pixels',...
        'parent',fig,...  
        'Color',[1 1 1],...
        'Position',[0 0 560,560],...
        'XLim',[-1200,1200],...
        'YLim',[-1200,1200],...
        'XColor','none',...
        'YColor','none');
hold(ax,'on')
ax.YDir='reverse';
ax.XDir='normal';



[XMesh,YMesh]=meshgrid(-1200:1:1200,-1200:1:1200);
disMesh=sqrt(XMesh.^2+YMesh.^2);
thetaMesh=atan2(YMesh,XMesh)+pi;
thetaMesh=thetaMesh(:,end:-1:1);

tempPic=1;
t=0:0.001:(2*pi+0.001);
for i=1:length(BlockNum)
    blockNum=BlockNum(i);
    Rrange=R(i,:);
    for j=1:blockNum
        tempBoard=ones(2401,2401)==1;
        tempBoard=tempBoard&(disMesh>Rrange(1))&(disMesh<Rrange(2));
        tempBoard=tempBoard&(thetaMesh>((j-1)*2*pi/blockNum))&(thetaMesh<(j*2*pi/blockNum));
        TrueX=find(sum(tempBoard,1)>0);
        TrueY=find(sum(tempBoard,2)>0);
        tempMask=tempBoard(min(TrueY):max(TrueY),min(TrueX):max(TrueX));
        x1=YMesh(min(TrueX),min(TrueY));
        y1=XMesh(min(TrueX),min(TrueY));
        x2=YMesh(max(TrueX),max(TrueY));
        y2=XMesh(max(TrueX),max(TrueY));
        xdiff=x2-x1;
        ydiff=y2-y1;
        
        pic=imgSet.(['p',num2str(tempPic)]);
        [rows,cols,~]=size(pic);
        ratio=[ydiff+1,xdiff+1]./[rows,cols];
        newsize=ceil([rows,cols].*max(ratio));
        offset=floor((newsize-[ydiff+1,xdiff+1])./2);
        pic=imresize(pic,newsize);
        pic=pic((1:ydiff+1)+offset(1),(1:xdiff+1)+offset(2),:);
        
        image(ax,[x1,x2],[y1,y2],pic,'alphaData',tempMask);
        tempPic=tempPic+1;
        tempPic=mod(tempPic-1,picNum)+1;
    end
    for j=1:blockNum
        plot(cos(j*2*pi/blockNum).*Rrange,sin(j*2*pi/blockNum).*Rrange,'Color',lineColor,'LineWidth',lineWidth)
    end
    plot(cos(t).*Rrange(1),sin(t).*Rrange(1),'Color',lineColor,'LineWidth',lineWidth)
    plot(cos(t).*Rrange(2),sin(t).*Rrange(2),'Color',lineColor,'LineWidth',lineWidth)
end

end
