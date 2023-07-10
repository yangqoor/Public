function lowPoly()
oriPic=imread('1.jpg');

% use sobel algorithm to detect image edges
if size(oriPic,3)==3
    grayPic=rgb2gray(oriPic);
else
    grayPic=oriPic;
end
sobelPic=sobelConv2_gray(grayPic);



edgePic=sobelPic;
edgePic(edgePic<max(max(edgePic)).*0.4)=0;
[edgeX,edgeY]=find(edgePic>0);
edgePntList=[edgeY,edgeX];

% set the triangle density
redge=min(size(sobelPic))/80;
rmax=min(size(sobelPic))/20;
rmin=min(size(sobelPic))/40;


% use poisson disc sampling to select points
edgePntList=poissonEdge(edgePntList,redge);
pntList=poissonDisk(sobelPic,[rmin,rmax],30,edgePntList);
% imshow(sobelPic)
% hold on
% scatter(pntList(:,1),pntList(:,2),3,'filled')

% construct the delone triangle
DT=delaunay(pntList(:,1),pntList(:,2));
%triplot(DT,pntList(:,1),pntList(:,2));

% calculate the pixel value at the center of gravity of the triangle
vset1=pntList(DT(:,1),:);
vset2=pntList(DT(:,2),:);
vset3=pntList(DT(:,3),:);
barycenter=round((vset1+vset2+vset3)./3);
tempList=barycenter(:,2)+(barycenter(:,1)-1)*size(oriPic,1);
if size(oriPic,3)==3   
    Rchannel=oriPic(:,:,1);
    Gchannel=oriPic(:,:,2);
    Bchannel=oriPic(:,:,3);
    colorList(:,:,1)=Rchannel(tempList);
    colorList(:,:,2)=Gchannel(tempList);
    colorList(:,:,3)=Bchannel(tempList);
else
    colorList(:,:,1)=oriPic(tempList);
    colorList(:,:,2)=oriPic(tempList);
    colorList(:,:,3)=oriPic(tempList);
end

% show picture
z=zeros([size(pntList,1),1]);
trisurf(DT,pntList(:,1),pntList(:,2),z,'CData',colorList,'EdgeColor','none')
ax=gca;
hold(ax,'on')
set(ax,'XTick',[],'YTick',[],'XColor','none','YColor','none')
axis equal
set(ax,'YDir','reverse','View',[0,90])


%% Correlation Functions============================================
    function resultSet=poissonEdge(edgeList,R)
        preSet=edgeList;
        resultSet=[0 0];
        resultSet(1,:)=[];
        
        times=0;
        while times<150
            tempPos=randi([1,size(preSet,1)],1);
            selectedPnt=preSet(tempPos,:);
            dis=sqrt(sum((edgeList-selectedPnt).^2,2));
            candidate=find(dis>=R&dis<=2*R);
            if length(candidate)>30
                pntSet=edgeList(candidate(1:30),:);
            else
                pntSet=edgeList(candidate,:);
            end
            
            flag=0;
            for j=1:size(pntSet,1)
                pnt=pntSet(j,:);
                if size(resultSet,1)==0
                    resultSet=[resultSet;pnt];
                    preSet=[preSet;pnt];
                    flag=1;
                else
                    dis=sqrt(sum((resultSet-pnt).^2,2));
                    if all(dis>=R)
                        resultSet=[resultSet;pnt];
                        preSet=[preSet;pnt];
                        flag=1;
                    end
                end
            end
            if flag==1
                preSet(tempPos,:)=[];times=0;
            else
                times=times+1;
            end 
            disp(['edge pnt num:',num2str(size(resultSet,1))]);
        end
    end


    function resultSet=poissonDisk(grayPic,R,K,edgePntList)
        [m,n]=size(grayPic);
        
        preSet=edgePntList;
        resultSet=[edgePntList;1,1;n,m;1,m;n,1];
        grayPic=double(255-grayPic);
        cmin=min(min(grayPic));
        cmax=max(max(grayPic));
        rMap=grayPic-cmin;
        rMap=rMap./(cmax-cmin).*(R(2)-R(1))+R(1);
        
        times=0;
        while times<500
            tempPos=randi([1,size(preSet,1)],1);
            selectedPnt=preSet(tempPos,:);
            r=rMap(round(selectedPnt(2)),round(selectedPnt(1)));
            theta=rand(K,1).*2*pi;
            radius=rand(K,1).*r+r;
            x=radius.*cos(theta)+selectedPnt(1);
            y=radius.*sin(theta)+selectedPnt(2);
            
            flag=0;
            for j=1:K
                pnt=[x(j),y(j)];
                if pnt(1)>=1&&pnt(2)>=1&&pnt(1)<=n&&pnt(2)<=m
                    if size(resultSet,1)==0
                        resultSet=[resultSet;pnt];
                        preSet=[preSet;pnt];
                        flag=1;
                    else
                        dis=sqrt(sum((resultSet-pnt).^2,2));
                        if all(dis>=r)
                            resultSet=[resultSet;pnt];
                            preSet=[preSet;pnt];
                            flag=1;   
                        end
                    end 
                end
            end
            if flag==1
                preSet(tempPos,:)=[];times=0;
            else
                times=times+1;
            end
            disp(['pnt num:',num2str(size(resultSet,1))]);
        end    
    end

    function sobelPic=sobelConv2_gray(oriPic)
        Hx=[-1 0 1;-2 0 2;-1 0 1];
        Hy=[1 2 1;0 0 0;-1 -2 -1];

        [rows,cols]=size(oriPic);
        exPic=uint8(zeros([rows+2,cols+2]));
        exPic(2:rows+1,2:cols+1)=oriPic;
        
        exPic(2:rows+1,1)=oriPic(:,1);
        exPic(2:rows+1,cols+2)=oriPic(:,cols);
        exPic(1,2:cols+1)=oriPic(1,:);
        exPic(rows+2,2:cols+1)=oriPic(rows,:);
        
        exPic(1,1)=oriPic(1,1);
        exPic(rows+2,1)=oriPic(rows,1);
        exPic(1,cols+2)=oriPic(1,cols);
        exPic(rows+2,cols+2)=oriPic(rows,cols);
        
        Gx=zeros([rows,cols]);Gy=Gx;
        
        for ii=1:3
            for jj=1:3
                tempPic=double(exPic(ii:rows+ii-1,jj:cols+jj-1));
                Gx=Gx+tempPic.*Hx(ii,jj);
                Gy=Gy+tempPic.*Hy(ii,jj);
            end
        end
        sobelPic=uint8(sqrt(Gx.^2+Gy.^2));
    end
end
