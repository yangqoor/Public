function colourAtla
% @author slandarer
% use k-means algorithm to generate
% a colour atla for a image

global colorNum colorList colorType oriPic RGBList 

% 颜色数量
colorNum=2;

% 初始颜色列表
colorList=[189  115  138; 237  173  158
           140  199  181; 120  205  205
            79  148  205; 205  150  205];
        
% 颜色格式
% [0 1]   -> 1
% [0 255] -> 2
% #hex    -> 3
% hsv     -> 4
colorType=3;

% 三维图片矩阵
oriPic=[];

% RGB数据列
RGBList=[];

% =========================================================================
% figure窗口构建
atlaFig=uifigure('units','pixels');
atlaFig.Position=[10,65,750,500];
atlaFig.NumberTitle='off';
atlaFig.MenuBar='none';
atlaFig.Name='colour atla 1.0 | by slandarer';
atlaFig.Color=[1,1,1];
atlaFig.Resize='off';
% 显示图像axes区域
imgAxes=uiaxes('Parent',atlaFig);
imgAxes.Position=[10,10,480,480];
imgAxes.XLim=[0,100];
imgAxes.YLim=[0,100];
imgAxes.XTick=[];
imgAxes.YTick=[];
imgAxes.Box='on';
imgAxes.Toolbar.Visible='off';
% 显示色卡axes区域
atlaAxes=uiaxes('Parent',atlaFig);
atlaAxes.Position=[500,90,240,400];
atlaAxes.XLim=[0,240];
atlaAxes.YLim=[0,400];
atlaAxes.XTick=[];
atlaAxes.YTick=[];
atlaAxes.Box='on';
atlaAxes.Toolbar.Visible='on';
hold(atlaAxes,'on')
% 重绘色卡函数
function freshColorAtla(~,~)
    hold(atlaAxes,'off')
    plot(atlaAxes,[-1,-1],[-1,-1]);
    hold(atlaAxes,'on')
    text(atlaAxes,10,370,'Colour Atla','FontName','Cambria','FontSize',21);
    for i=1:size(colorList,1)
        fill(atlaAxes,[10 120 120 10],[370 370 390 390]-50-28*(i-1),colorList(i,:)./255)
        switch colorType
            case 1 % 显示RGB [0 1]格式颜色数据
                tempColorR=sprintf('%.2f',colorList(i,1)./255);
                tempColorG=sprintf('%.2f',colorList(i,2)./255);
                tempColorB=sprintf('%.2f',colorList(i,3)./255);
                text(atlaAxes,133,330-28*(i-1),...
                    [tempColorR,' ',tempColorG,' ',tempColorB],...
                    'FontName','Cambria','FontSize',16);
            case 2 % 显示RGB[0 255]格式颜色数据
                text(atlaAxes,135,330-28*(i-1),...
                    [num2str(colorList(i,1)),' ',...
                     num2str(colorList(i,2)),' ',...
                     num2str(colorList(i,3))],...
                    'FontName','Cambria','FontSize',16);
            case 3 % 显示16进制格式颜色数据
                exchange_list={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
                tempColor16='#';
                for ii=1:3
                    temp_num=colorList(i,ii);
                    tempColor16(1+ii*2-1)=exchange_list{(temp_num-mod(temp_num,16))/16+1};
                    tempColor16(1+ii*2)=exchange_list{mod(temp_num,16)+1};
                end
                text(atlaAxes,135,330-28*(i-1),tempColor16,'FontName','Cambria','FontSize',16);
            case 4 % 显示hsv格式颜色数据
                [h,s,v]=rgb2hsv(colorList(i,1),colorList(i,2),colorList(i,3));
                text(atlaAxes,130,330-28*(i-1),...
                    [sprintf('%.2f',h),'  ',...
                     sprintf('%.2f',s),'  ',...
                     num2str(v)],...
                     'FontName','Cambria','FontSize',16);
        end
    end
    outputData()
end
freshColorAtla()

% =========================================================================
% 选择k-means k值按钮（颜色数量按钮）
uilabel('parent',atlaFig,'Text','  ColorNum','FontName','Cambria','FontWeight','bold',...
    'FontSize',15,'BackgroundColor',[0.31 0.58 0.80],'position',[500,50,80,25],'FontColor',[1 1 1]);
CNsetBtn=uispinner(atlaFig,'Value',2,'limit',[2 12],'FontName','Cambria','Step',1,...
    'ValueDisplayFormat','%.f','FontSize',14,'ValueChangedFcn',@CNset,'position',[580,50,50,25]);
function CNset(~,~)% color number set function
    colorNum=CNsetBtn.Value;  
end
% 选择颜色类型按钮
uilabel('parent',atlaFig,'Text','  ColorType','FontName','Cambria','FontWeight','bold',...
    'FontSize',15,'BackgroundColor',[0.31 0.58 0.80],'position',[500,15,90,25],'FontColor',[1 1 1]);
TPsetBtnGp=uidropdown('parent',atlaFig);
TPsetBtnGp.Items={'  [0 1]';'[0 255]';'  #hex';'  HSV'};
TPsetBtnGp.ValueChangedFcn=@TPset;
TPsetBtnGp.Position=[580,15,70,25];
TPsetBtnGp.Value='  #hex';
function TPset(~,~)% color type set function
    switch TPsetBtnGp.Value
        case '  [0 1]',colorType=1;
        case '[0 255]',colorType=2;
        case '  #hex', colorType=3;
        case '  HSV',  colorType=4;
    end
    freshColorAtla()
end
% 导入图片按钮
uibutton(atlaFig,'Text','Load Img','BackgroundColor',[0.59 0.71 0.84],'FontColor',[1 1 1],...
    'FontWeight','bold','Position',[640,50,100,25],'FontName','Cambria','FontSize',15,'ButtonPushedFcn',@LDimg);
function LDimg(~,~)
    try
        [filename, pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files' });
        oriPic=imread([pathname,filename]);
        [imgXLim,imgYLim,~]=size(oriPic);
        len=max([imgXLim,imgYLim]);
        imgAxes.XLim=[0 len];
        imgAxes.YLim=[0 len];
        hold(imgAxes,'off')
        imshow(oriPic,'Parent',imgAxes)
        
        Rchannel=oriPic(:,:,1);
        Gchannel=oriPic(:,:,2);
        Bchannel=oriPic(:,:,3);
        RGBList=double([Rchannel(:),Gchannel(:),Bchannel(:)]);
    catch
    end
end
% 开始聚类按钮
uibutton(atlaFig,'Text','RUN','BackgroundColor',[0.59 0.71 0.84],'FontColor',[1 1 1],...
    'FontWeight','bold','Position',[660,15,80,25],'FontName','Cambria','FontSize',15,'ButtonPushedFcn',@runKmeans);
function runKmeans(~,~)
    [~,C]=kmeans(RGBList,colorNum,'Distance','sqeuclidean','MaxIter',1000,'Display','iter');
    
    % 以下为聚类结束后的重排序，
    % 依据RGB矩阵均值最大列为正权重
    % RGB均值次大、最小列为正权重
    % 对颜色数组进行重排序[为了更好的视觉效果]
    C=round(C);
    cmean=mean(C,1);
    [~,cindex]=sort(cmean,'descend');
    coe=zeros(3,1);
    coe(cindex(1))=1;
    coe(cindex(2))=-0.4;
    coe(cindex(3))=-0.6;
    [~,index]=sort(C*coe,'descend');
    C=C(index,:);
    
    colorList=C;
    freshColorAtla()
end
% 命令行输出数据函数
function outputData(~,~)
    disp(['output time:',datestr(now)])
    disp('color list:')
    for i=1:size(colorList,1)
        switch colorType % 与色卡显示类似
            case 1
                tempData(i,:)=roundn(colorList(i,:)./255,-2);
            case 2
                tempData(i,:)=colorList(i,:);
            case 3
                exchange_list={'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
                tempColor16='#';
                for ii=1:3
                    temp_num=colorList(i,ii);
                    tempColor16(1+ii*2-1)=exchange_list{(temp_num-mod(temp_num,16))/16+1};
                    tempColor16(1+ii*2)=exchange_list{mod(temp_num,16)+1};
                end
                tempData(i,1)={tempColor16};
            case 4
                [h,s,v]=rgb2hsv(colorList(i,1),colorList(i,2),colorList(i,3));
                tempData(i,:)=[h,s,v];
        end
    end
    disp(tempData);
end
end














