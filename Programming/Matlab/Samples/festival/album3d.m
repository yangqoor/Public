function album3d
path='.\';%文件夹名称
files=dir(fullfile(path,'*.jpg')); 
picNum=size(files,1);

%遍历路径下每一幅图像
for i=1:picNum
   fileName=strcat(path,files(i).name); 
   img=imread(fileName);
   img=imresize(img,[120,120]);
   imgSet{i}=img;
end

% fig axes设置
fig=figure('units','pixels','position',[50 50 600 600],...
                       'Numbertitle','off','resize','off',...
                       'name','album3d','menubar','none');
ax=axes('parent',fig,'position',[-0.5 -0.5 2 2],...
   'XLim', [-6 6],...
   'YLim', [-6 6],...
   'ZLim', [-6 6],...
   'Visible','on',...
   'XTick',[], ...
   'YTick',[],...
   'Color',[0 0 0],...
   'DataAspectRatioMode','manual',...
   'CameraPositionMode','manual');
hold(ax,'on')
ax.CameraPosition=[5 5 5];

% 用于绘制图片的网格
[XMesh,YMesh]=meshgrid(linspace(-1,1,120),linspace(-1,1,120));
ZMesh=ones(120,120);

% 绘制图片立方体
surfPic(1)=surf(XMesh,YMesh,ZMesh,'CData',imgSet{mod(0,picNum)+1},'EdgeColor','none','FaceColor','interp');
surfPic(2)=surf(XMesh,YMesh(end:-1:1,:),-ZMesh,'CData',imgSet{mod(1,picNum)+1},'EdgeColor','none','FaceColor','interp');
surfPic(3)=surf(ZMesh,XMesh,YMesh(end:-1:1,:),'CData',imgSet{mod(2,picNum)+1},'EdgeColor','none','FaceColor','interp');
surfPic(4)=surf(XMesh,ZMesh,YMesh(end:-1:1,:),'CData',imgSet{mod(3,picNum)+1},'EdgeColor','none','FaceColor','interp');
surfPic(5)=surf(-ZMesh,XMesh,YMesh(end:-1:1,:),'CData',imgSet{mod(4,picNum)+1},'EdgeColor','none','FaceColor','interp');
surfPic(6)=surf(XMesh,-ZMesh,YMesh(end:-1:1,:),'CData',imgSet{mod(5,picNum)+1},'EdgeColor','none','FaceColor','interp');

% 依靠小立方体数据绘制中等立方体
for i=1:6
    surfPicA(i)=surf(surfPic(i).XData.*1.5,surfPic(i).YData.*1.5,surfPic(i).ZData.*1.5,...
        'CData',surfPic(i).CData,'EdgeColor','none','FaceColor','interp','FaceAlpha',0.7);  
end

% 用来调整放大比例的矩阵
resizeMat=[2 2 2.5;2 2 2.5;2.5 2 2;
           2 2.5 2;2.5 2 2;2 2.5 2];

% 最大图片绘制       
% for i=1:6
%     surfPicB(i)=surf(surfPic(i).XData.*resizeMat(i,1),...
%                      surfPic(i).YData.*resizeMat(i,2),...
%                      surfPic(i).ZData.*resizeMat(i,3),...
%                      'CData',surfPic(i).CData,'EdgeColor',...
%                      'none','FaceColor','interp','FaceAlpha',0.7);  
% end     


lastDis=300;
preDis=300;
set(fig,'WindowButtonMotionFcn',@move2center)    
    function move2center(~,~)
        xy=get(fig,'CurrentPoint');
        preDis=sqrt(sum((xy-[300,300]).^2));
    end



fps=40;theta=0;
rotateTimer=timer('ExecutionMode', 'FixedRate', 'Period',1/fps, 'TimerFcn', @rotateCube);
start(rotateTimer)



    function rotateCube(~,~)
        theta=theta+0.02;
        ax.CameraPosition=[cos(theta)*5*sqrt(2),sin(theta)*5*sqrt(2),5];
        if (~all([preDis lastDis]<150))&&any([preDis lastDis]<150)
            for ii=1:6
                if preDis<150
                    surfPicA(ii).XData=surfPic(ii).XData.*resizeMat(ii,1);
                    surfPicA(ii).YData=surfPic(ii).YData.*resizeMat(ii,2);
                    surfPicA(ii).ZData=surfPic(ii).ZData.*resizeMat(ii,3);
                else
                    surfPicA(ii).XData=surfPic(ii).XData.*1.5;
                    surfPicA(ii).YData=surfPic(ii).YData.*1.5;
                    surfPicA(ii).ZData=surfPic(ii).ZData.*1.5;
                end
            end
        end
        lastDis=preDis;
    end




% 弃用方案：太卡
% set(fig,'WindowButtonMotionFcn',@move2center)    
%     function move2center(~,~)
%         xy=get(fig,'CurrentPoint');
%         dis=sum((xy-[300,300]).^2);
%         for ii=1:6
%             if dis<200
%                 surfPicA(ii).XData=surfPic(ii).XData.*resizeMat(ii,1);
%                 surfPicA(ii).YData=surfPic(ii).YData.*resizeMat(ii,2);
%                 surfPicA(ii).ZData=surfPic(ii).ZData.*resizeMat(ii,3);
%             else
%                 surfPicA(ii).XData=surfPic(ii).XData;
%                 surfPicA(ii).YData=surfPic(ii).YData;
%                 surfPicA(ii).ZData=surfPic(ii).ZData;
%             end    
%         end
%         
%         
%         
%     end

end
