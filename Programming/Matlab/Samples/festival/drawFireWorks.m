function drawFireWorks
blackPic=uint8(zeros(800,800));
distPic=imnoise(blackPic,'gaussian',0, 0.1);
distPic(distPic<254)=0;

se=strel('square',3);
distPic=imdilate(distPic,se);

windPic=wind(distPic,180,0.99);

polarPic=polarTransf(windPic(:,end:-1:1)');


polarPic=imgaussfilt(polarPic,1.5);
polarPic=uint8(double(polarPic)./double(max(max(polarPic))).*260);
imshow(polarPic)
%-----------------------------------------------------------------
matSize=[1600,1600];
point=[800,800];
colorList=[255   253   255
   255   255   244
   250   255   219
   212   242   156
    90   167     3
    32    96     0
    56    82     0];
% colorList2=[25    59   157
%     24    71   219
%     38   124   237
%     93   215   255
%    168   244   255
%    243   254   250
%    246   252   240];
% colorList3=[239   250   210
%    229   164   122
%    232   150   138
%    255   164   204
%    192    58   111
%    158    10    26
%    224   168   121];
colorMat=cColorMat(matSize,point,colorList);

colorMatR=colorMat(:,:,1);
colorMatG=colorMat(:,:,2);
colorMatB=colorMat(:,:,3);
fwPicR=double(colorMatR).*double(polarPic)./255;
fwPicG=double(colorMatG).*double(polarPic)./255;
fwPicB=double(colorMatB).*double(polarPic)./255;
fwPic(:,:,1)=fwPicR;
fwPic(:,:,2)=fwPicG;
fwPic(:,:,3)=fwPicB;
fwPic=uint8(fwPic);
imshow(fwPic)



%==========================================================================
    function resultPic=wind(oriPic,len,ratio)
        oriPic=double(oriPic);
        for i=1:len
            tempPic=[zeros(size(oriPic,1),1),oriPic(:,1:(end-1))].*ratio;
            oriPic(oriPic<tempPic)=tempPic(oriPic<tempPic);  
        end
        resultPic=uint8(oriPic);
    end
    
    function resultPic=polarTransf(oriPic)
        oriPic=double(oriPic);
        [m,n]=size(oriPic);
        [t,r]=meshgrid(linspace(-pi,pi,n),1:m);
        
        M=2*m;
        N=2*n;
        [NN,MM]=meshgrid((1:N)-n-0.5,(1:M)-m-0.5);
        T=atan2(NN,MM);
        R=sqrt(MM.^2+NN.^2);
        
        resultPic=interp2(t,r,oriPic,T,R,'linear',0);
        resultPic=uint8(resultPic);
    end
%==========================================================================
    function colorMat=cColorMat(matSize,point,colorList)
    % matSize=[800,600];
    % point=[400,100];
    % colorList=[195    53    93
    %    211   102   141
    %    231   179   192
    %    229   182   172
    %    227   178   137
    %    238   191   147
    %    236   195   113];
    % colorMat=cColorMat(matSize,point,colorList);
    % imshow(colorMat)

    [xMesh,yMesh]=meshgrid(1:matSize(2),1:matSize(1));
    zMesh=sqrt((xMesh-point(2)).^2+(yMesh-point(1)).^2);
    zMesh=(zMesh-min(min(zMesh)))./(max(max(zMesh))-min(min(zMesh)));

    colorFunc=colorFuncFactory(colorList);
    colorMesh=colorFunc(zMesh);

    colorMat(:,:,1)=colorMesh(end:-1:1,1:matSize(1));
    colorMat(:,:,2)=colorMesh(end:-1:1,matSize(1)+1:2*matSize(1));
    colorMat(:,:,3)=colorMesh(end:-1:1,2*matSize(1)+1:3*matSize(1));

    colorMat=uint8(colorMat);

    end

    function colorFunc=colorFuncFactory(colorList)
        x=(0:size(colorList,1)-1)./(size(colorList,1)-1);
        y1=colorList(:,1);y2=colorList(:,2);y3=colorList(:,3);
        colorFunc=@(X)[interp1(x,y1,X,'linear')',interp1(x,y2,X,'linear')',interp1(x,y3,X,'linear')'];
    end


end
