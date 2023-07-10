function OrigamiApp
%该软件仿自oripa以及几何画板

%全局变量>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
global LineColor_ PointColor_ LineWidth_ PointWidth_ LineType_ theta
global LineSet CircleSet PointSet pointSet_forDraw LineNum CircleNum PointNum stdPointSet
global selectedType buttonList
global ThreeStagesStatus ThreePointsSet
global Xvalue Yvalue
global PointerHdl ThreePointsHdl
global LHdl CHdl PHdl

LineColor_=[0 0.4470 0.7410];LineWidth_=2;LineType_='-';
PointColor_=[0.5843 0.2157 0.2078];PointWidth_=55;


LineSet=[0 0 0 0 0 0 0];LineSet(1,:)=[];
CircleSet=[0 0 0];CircleSet(1,:)=[];CircleNum=[];

LineNum=[];CircleNum=[];PointNum=[];

selectedType='dLL2P';
buttonList={'dLL2P','dL2P','drL2P','dpL3P','dC2P','dC3P','diC3P',...
            'dbL3P','dvL2P','dvL3P','dmP','deP','deLL2P','deC2P'};
theta=0:0.05:2*pi+0.05;

% LineSetX=[zeros(21,1),ones(21,1),(-10:10)',-10.*ones(21,1),(-10:10)',10.*ones(21,1),(-10:10)'];
% LineSetY=[ones(21,1),zeros(21,1),(-10:10)',(-10:10)',-10.*ones(21,1),(-10:10)',10.*ones(21,1)];
% LineSet=[LineSetX;LineSetY];

[stdPointSetX,stdPointSetY]=meshgrid(-10:10);
stdPointSet=[stdPointSetX(:),stdPointSetY(:)];
pointSet_forDraw=[0 0];
pointSet_forDraw(1,:)=[];
PointSet=[0 0];
PointSet(1,:)=[];

ThreeStagesStatus=1;
ThreePointsSet=[0 0;0 0;0 0];



%界面制作>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
OriPa_Fig=uifigure('units','pixels');
OriPa_Fig.Position=[10,65,790,620];
OriPa_Fig.NumberTitle='off';
OriPa_Fig.MenuBar='none';
OriPa_Fig.Name='Origami App';
OriPa_Fig.Color=[1,1,1];
OriPa_Fig.Resize='off';
OriPa_Fig.WindowButtonMotionFcn=@windowButtonMotion;
OriPa_Fig.WindowButtonDownFcn=@windowButtonDown;

OriPa_Axes=uiaxes('Parent',OriPa_Fig);
OriPa_Axes.Position=[10,10,600,600];
OriPa_Axes.XLim=[-10,10];
OriPa_Axes.YLim=[-10,10];
OriPa_Axes.XTick=-10:10;
OriPa_Axes.YTick=-10:10;
OriPa_Axes.Box='on';
OriPa_Axes.XGrid='on';
OriPa_Axes.YGrid='on';
OriPa_Axes.XTickLabel={};
OriPa_Axes.YTickLabel={};
% OriPa_Axes.XTick=[];
% OriPa_Axes.YTick=[];
% OriPa_Axes.XColor='none';
% OriPa_Axes.YColor='none';
OriPa_Axes.Toolbar.Visible='off';
hold(OriPa_Axes,'on');
%按钮 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%绘制线段
OriPa_Button.dLL2P=uiimage(OriPa_Fig');
OriPa_Button.dLL2P.Position=[620 532.5 75 75];
OriPa_Button.dLL2P.ImageSource='button ico\dLL2P_1.png';
OriPa_Button.dLL2P.UserData='dLL2P';
%绘制直线
OriPa_Button.dL2P=uiimage(OriPa_Fig');
OriPa_Button.dL2P.Position=[620 532.5-85 75 75];
OriPa_Button.dL2P.ImageSource='button ico\dL2P_0.png';
OriPa_Button.dL2P.UserData='dL2P';
%绘制射线
OriPa_Button.drL2P=uiimage(OriPa_Fig');
OriPa_Button.drL2P.Position=[620 532.5-2*85 75 75];
OriPa_Button.drL2P.ImageSource='button ico\drL2P_0.png';
OriPa_Button.drL2P.UserData='drL2P';
%绘制射线
OriPa_Button.dpL3P=uiimage(OriPa_Fig');
OriPa_Button.dpL3P.Position=[620 532.5-3*85 75 75];
OriPa_Button.dpL3P.ImageSource='button ico\dpL3P_0.png';
OriPa_Button.dpL3P.UserData='dpL3P';
%两点绘圆
OriPa_Button.dC2P=uiimage(OriPa_Fig');
OriPa_Button.dC2P.Position=[620 532.5-4*85 75 75];
OriPa_Button.dC2P.ImageSource='button ico\dC2P_0.png';
OriPa_Button.dC2P.UserData='dC2P';
%三点绘圆
OriPa_Button.dC3P=uiimage(OriPa_Fig');
OriPa_Button.dC3P.Position=[620 532.5-5*85 75 75];
OriPa_Button.dC3P.ImageSource='button ico\dC3P_0.png';
OriPa_Button.dC3P.UserData='dC3P';
%内切圆
OriPa_Button.diC3P=uiimage(OriPa_Fig');
OriPa_Button.diC3P.Position=[620 532.5-6*85 75 75];
OriPa_Button.diC3P.ImageSource='button ico\diC3P_0.png';
OriPa_Button.diC3P.UserData='diC3P';
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%绘制角平分线
OriPa_Button.dbL3P=uiimage(OriPa_Fig');
OriPa_Button.dbL3P.Position=[620+85 532.5 75 75];
OriPa_Button.dbL3P.ImageSource='button ico\dbL3P_0.png';
OriPa_Button.dbL3P.UserData='dbL3P';
%绘制中垂线
OriPa_Button.dvL2P=uiimage(OriPa_Fig');
OriPa_Button.dvL2P.Position=[620+85 532.5-85 75 75];
OriPa_Button.dvL2P.ImageSource='button ico\dvL2P_0.png';
OriPa_Button.dvL2P.UserData='dvL2P';
%绘制垂线
OriPa_Button.dvL3P=uiimage(OriPa_Fig');
OriPa_Button.dvL3P.Position=[620+85 532.5-2*85 75 75];
OriPa_Button.dvL3P.ImageSource='button ico\dvL3P_0.png';
OriPa_Button.dvL3P.UserData='dvL3P';
%绘制中点
OriPa_Button.dmP=uiimage(OriPa_Fig');
OriPa_Button.dmP.Position=[620+85 532.5-3*85 75 75];
OriPa_Button.dmP.ImageSource='button ico\dmP_0.png';
OriPa_Button.dmP.UserData='dmP';
%删除点
OriPa_Button.deP=uiimage(OriPa_Fig');
OriPa_Button.deP.Position=[620+85 532.5-4*85 75 75];
OriPa_Button.deP.ImageSource='button ico\deP_0.png';
OriPa_Button.deP.UserData='deP';
%删除线
OriPa_Button.deLL2P=uiimage(OriPa_Fig');
OriPa_Button.deLL2P.Position=[620+85 532.5-5*85 75 75];
OriPa_Button.deLL2P.ImageSource='button ico\deLL2P_0.png';
OriPa_Button.deLL2P.UserData='deLL2P';
%删除圆
OriPa_Button.deC2P=uiimage(OriPa_Fig');
OriPa_Button.deC2P.Position=[620+85 532.5-6*85 75 75];
OriPa_Button.deC2P.ImageSource='button ico\deC2P_0.png';
OriPa_Button.deC2P.UserData='deC2P';
for i=1:length(buttonList)
    OriPa_Button.(buttonList{i}).ImageClickedFcn=@buttonClicked;
end
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
PointerHdl=scatter3(OriPa_Axes,[],[],[],75,'filled','CData',[0.7373 0.4549 0.5412],'MarkerEdgeColor',[0.3 0.3 0.3],'LineWidth',1);
ThreePointsHdl=scatter3(OriPa_Axes,[],[],[],55,'filled','CData',[0.7373 0.4549 0.5412]);%0.5843 0.2157 0.2078
%scatter3(OriPa_Axes,[],[],[],55,'filled','CData',PointColor_);

%回调函数>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%改变功能
function buttonClicked(~,event)
    OriPa_Button.(selectedType).ImageSource=['button ico\',selectedType,'_0.png'];
    selectedType=event.Source.UserData;
    OriPa_Button.(selectedType).ImageSource=['button ico\',selectedType,'_1.png'];
    ThreeStagesStatus=1;
    ThreePointsHdl.XData=[];
    ThreePointsHdl.YData=[];
    ThreePointsHdl.ZData=[];
end
%鼠标移动- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function windowButtonMotion(~,~)
    xy=OriPa_Fig.CurrentPoint;
    Xvalue=xy(1);
    Yvalue=xy(2);
    if Xvalue>=10&&Xvalue<=610&&Yvalue>=10&&Yvalue<=610
        xyInAxes=OriPa_Axes.CurrentPoint;
        Xvalue=xyInAxes(1,1);Xvalue(Xvalue>10)=10;Xvalue(Xvalue<-10)=-10;
        Yvalue=xyInAxes(1,2);Yvalue(Yvalue>10)=10;Yvalue(Yvalue<-10)=-10;
        Point=getClosest([stdPointSet;PointSet],[Xvalue,Yvalue]);
        if ~isempty(Point)
                    Xvalue=Point(1);Yvalue=Point(2);
                    PointerHdl.XData=Xvalue;
                    PointerHdl.YData=Yvalue;
                    PointerHdl.ZData=2;
                else
                    PointerHdl.XData=[];
                    PointerHdl.YData=[];
                    PointerHdl.ZData=[];
        end
    else 
        
    end
end

%鼠标点击- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
function windowButtonDown(~,~)
    xy=OriPa_Fig.CurrentPoint;
    x=xy(1);
    y=xy(2);
    if x>=10&&x<=610&&y>=10&&y<=610
        ThreePointsSet(ThreeStagesStatus,:)=[Xvalue,Yvalue];
        ThreePointsHdl.XData=ThreePointsSet(1:ThreeStagesStatus,1);
        ThreePointsHdl.YData=ThreePointsSet(1:ThreeStagesStatus,2);
        ThreePointsHdl.ZData=ones(ThreeStagesStatus,1).*1.5;
        ThreeStagesStatus=ThreeStagesStatus+1;
    else
        ThreeStagesStatus=1;
        ThreePointsHdl.XData=[];
        ThreePointsHdl.YData=[];
        ThreePointsHdl.ZData=[];
    end
    if ThreeStagesStatus==3&&all(ThreePointsSet(1,:)==ThreePointsSet(2,:))
        setPoint(ThreePointsSet(1,:));
        PointSet=[PointSet;ThreePointsSet(1,:)];
        PointSet=unique(PointSet,'rows');
        ThreeStagesStatus=1;
    else   
        switch selectedType
            case 'dLL2P'%画线段
                if ThreeStagesStatus==3
                    points=ThreePointsSet(1:2,:);
                    [Line,p1,p2]=getLineL(points);
                    PointSet=[PointSet;p1;p2];
                    PointSet=unique(PointSet,'rows');
                    setPoint(p1)
                    setPoint(p2)
                    setLine(Line,p1,p2);
                    ThreeStagesStatus=1;
                end
            case 'dL2P'%画直线
                if ThreeStagesStatus==3
                    p1=ThreePointsSet(1,:);
                    p2=ThreePointsSet(2,:);
                    [p3,p4]=getEdgePoint(p1,p2);
                    PointSet=[PointSet;p1;p2;p3;p4];
                    PointSet=unique(PointSet,'rows');
                    setPoint(p1)
                    setPoint(p2)
                    [Line,p1,p2]=getLineL([p3;p4]);
                    setLine(Line,p1,p2);
                    ThreeStagesStatus=1;
                end
            case 'drL2P'%画射线
                if ThreeStagesStatus==3
                    p1=ThreePointsSet(1,:);
                    p2=ThreePointsSet(2,:);
                    [p3,~]=getEdgePoint(p1,p2);
                    PointSet=[PointSet;p1;p2;p3];
                    PointSet=unique(PointSet,'rows');
                    setPoint(p1)
                    setPoint(p2)
                    [Line,p1,p2]=getLineL([p1;p3]);
                    setLine(Line,p1,p2);
                    ThreeStagesStatus=1;
                end
            case 'dpL3P'%画平行线
                if ThreeStagesStatus==4
                    p1=ThreePointsSet(1,:);
                    p2=ThreePointsSet(2,:);
                    p3=ThreePointsSet(3,:);
                    if det([p1-p2;p1-p3])~=0
                        p4=p3+p2-p1;
                        [p5,p6]=getEdgePoint(p3,p4);
                        PointSet=[PointSet;p1;p2;p3;p5;p6];
                        PointSet=unique(PointSet,'rows');
                        setPoint(p1)
                        setPoint(p2)
                        setPoint(p3)
                        [Line,p1,p2]=getLineL([p5;p6]);
                        setLine(Line,p1,p2);
                    end
                    ThreeStagesStatus=1;
                end
            case 'dC2P'%画圆
                if ThreeStagesStatus==3
                    O=ThreePointsSet(1,:);
                    R=norm(O-ThreePointsSet(2,:));
                    PointSet=[PointSet;O;ThreePointsSet(2,:)];
                    PointSet=unique(PointSet,'rows');
                    setPoint(O)
                    setPoint(ThreePointsSet(2,:))
                    setCircle(O,R);
                    ThreeStagesStatus=1;
                end
            case 'dC3P'%画外接圆
                if ThreeStagesStatus==4
                    p1=ThreePointsSet(1,:);
                    p2=ThreePointsSet(2,:);
                    p3=ThreePointsSet(3,:);
                    if det([p1-p2;p1-p3])~=0
                        v2=(p2-p1)./norm(p2-p1);v2=[v2(2),-v2(1)];
                        v3=(p3-p1)./norm(p3-p1);v3=[v3(2),-v3(1)];
                        Points2=[(p1+p2)./2;(p1+p2)./2+v2];
                        Points3=[(p1+p3)./2;(p1+p3)./2+v3];
                        [Line2,~,~]=getLineL(Points2);
                        [Line3,~,~]=getLineL(Points3);
                        O=getCrossPoint_LL([Line2(1:3),-inf,-inf,inf,inf],[Line3(1:3),-inf,-inf,inf,inf]);
                        R=norm(p1-O);
                        PointSet=[PointSet;O;p1;p2;p3];
                        PointSet=unique(PointSet,'rows');
                        setPoint(O)
                        setPoint(p1)
                        setPoint(p2)
                        setPoint(p3)
                        setCircle(O,R);
                    end
                    ThreeStagesStatus=1;
                end
            case 'diC3P'%画内切圆
                if ThreeStagesStatus==4
                    p1=ThreePointsSet(1,:);
                    p2=ThreePointsSet(2,:);
                    p3=ThreePointsSet(3,:);
                    if det([p1-p2;p1-p3])~=0
                        v21=(p1-p2)./norm(p1-p2);
                        v23=(p3-p2)./norm(p3-p2);
                        v31=(p1-p3)./norm(p1-p3);
                        v32=(p2-p3)./norm(p2-p3);
                        v22=(v21+v23)./2;
                        v33=(v31+v32)./2;
                        points2=[p2;p2+v22];
                        points3=[p3;p3+v33];
                        [Line2,~,~]=getLineL(points2);
                        [Line3,~,~]=getLineL(points3);

                        O=getCrossPoint_LL([Line2(1:3),-inf,-inf,inf,inf],[Line3(1:3),-inf,-inf,inf,inf]);
                        
                        v14=[v31(2),-v31(1)];
                        v24=[v21(2),-v21(1)];
                        v34=[v23(2),-v23(1)];
                        [Line14,~,~]=getLineL([O;O+v14]);
                        [Line24,~,~]=getLineL([O;O+v24]);
                        [Line34,~,~]=getLineL([O;O+v34]);
                        [Line15,~,~]=getLineL([p1;p3]);
                        [Line25,~,~]=getLineL([p1;p2]);
                        [Line35,~,~]=getLineL([p2;p3]);
                        p14=getCrossPoint_LL([Line14(1:3),-inf,-inf,inf,inf],[Line15(1:3),-inf,-inf,inf,inf]);
                        p24=getCrossPoint_LL([Line24(1:3),-inf,-inf,inf,inf],[Line25(1:3),-inf,-inf,inf,inf]);
                        p34=getCrossPoint_LL([Line34(1:3),-inf,-inf,inf,inf],[Line35(1:3),-inf,-inf,inf,inf]);

                        R=norm(p14-O);
                        PointSet=[PointSet;O;p1;p2;p3;p14;p24;p34];
                        PointSet=unique(PointSet,'rows');
                        setPoint(O)
                        setPoint(p1)
                        setPoint(p2)
                        setPoint(p3)
                        setPoint(p14)
                        setPoint(p24)
                        setPoint(p34)
                        setCircle(O,R);
                    end
                    ThreeStagesStatus=1;
                end
            case 'dbL3P'%绘制角平分线
                if ThreeStagesStatus==4
                    p1=ThreePointsSet(1,:);
                    p2=ThreePointsSet(2,:);
                    p3=ThreePointsSet(3,:);
                    v1=p2-p1;v1=v1./norm(v1);
                    v2=p3-p1;v2=v2./norm(v2);
                    if det([v1;v2])~=0
                        v3=(v1+v2)./2;
                        p4=p1+v3;
                        [p5,~]=getEdgePoint(p1,p4);
                        PointSet=[PointSet;p1;p2;p3;p5];
                        PointSet=unique(PointSet,'rows');
                        setPoint(p1)
                        setPoint(p2)
                        setPoint(p3)
                        [Line,p1,p2]=getLineL([p1;p5]);
                        setLine(Line,p1,p2);
                    end
                    ThreeStagesStatus=1;
                end
            case 'dvL2P'%绘制中垂线
                if ThreeStagesStatus==3
                    p1=ThreePointsSet(1,:);
                    p2=ThreePointsSet(2,:);
                    p3=(p2+p1)./2;
                    v=p2-p1;
                    v=[v(2),-v(1)];
                    p4=p3+v;
                    [p5,p6]=getEdgePoint(p3,p4);
                    PointSet=[PointSet;p1;p2;p3;p5;p6];
                    PointSet=unique(PointSet,'rows');
                    setPoint(p1)
                    setPoint(p2)
                    setPoint(p3)
                    [Line,p1,p2]=getLineL([p5;p6]);
                    setLine(Line,p1,p2);
                    ThreeStagesStatus=1;
                end
            case 'dvL3P'%绘制垂线
                if ThreeStagesStatus==4
                    p1=ThreePointsSet(1,:);
                    p2=ThreePointsSet(2,:);
                    p3=ThreePointsSet(3,:);
                    if det([p1-p2;p1-p3])~=0
                        v=p2-p1;
                        v=[v(2),-v(1)];
                        p4=p3+v;
                        [Line1,~,~]=getLineL([p1;p2]);
                        [Line2,~,~]=getLineL([p3;p4]);
                        p5=getCrossPoint_LL([Line1(1:3),-inf,-inf,inf,inf],[Line2(1:3),-inf,-inf,inf,inf]);
                        PointSet=[PointSet;p1;p2;p3;p5];
                        PointSet=unique(PointSet,'rows');
                        setPoint(p1)
                        setPoint(p2)
                        setPoint(p3)
                        setPoint(p5)
                        [Line,p1,p2]=getLineL([p3;p5]);
                        setLine(Line,p1,p2);
                    end
                    ThreeStagesStatus=1;
                end
            case 'dmP'  %绘制中点
                if ThreeStagesStatus==3
                    p1=ThreePointsSet(1,:);
                    p2=ThreePointsSet(2,:);
                    p3=(p1+p2)./2;
                    PointSet=[PointSet;p3];
                    PointSet=unique(PointSet,'rows');
                    setPoint(p3)
                    ThreeStagesStatus=1;
                end
            case 'deP'%删除点
                if ThreeStagesStatus==2
                    setPoint(ThreePointsSet(1,:),1);
                    ThreeStagesStatus=1;
                end
            case 'deLL2P'%删除线段
                if ThreeStagesStatus==3
                    points=ThreePointsSet(1:2,:);
                    [~,p1,p2]=getLineL(points);
                    deleteLine(p1,p2);
                    ThreeStagesStatus=1;
                end
            case 'deC2P'%删除圆
                if ThreeStagesStatus==3
                    O=ThreePointsSet(1,:);
                    R=norm(O-ThreePointsSet(2,:));
                    deleteCircle(O,R);
                    ThreeStagesStatus=1;
                end
        end
    end
end

%功能函数>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%获取两线段交点- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function Point=getCrossPoint_LL(Line1,Line2)
thetaMat=[Line1(1,1:2);Line2(1,1:2)];
R=[Line1(3);Line2(3)];
if det(thetaMat)==0
    Point=[];
else
    Point=(thetaMat\R)';
    if pointInLine(Line1,Point)&&pointInLine(Line2,Point)
    else
        Point=[];
    end
end
end
%获取两圆交点- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function Point=getCrossPoint_CC(Circle1,Circle2)
x1=Circle1(1);y1=Circle1(2);r1=Circle1(3);
x2=Circle2(1);y2=Circle2(2);r2=Circle2(3);
cost=x2-x1;
sint=y2-y1;
r=(r1^2-r2^2)/2+(x2^2-x1^2)/2+(y2^2-y1^2)/2;
if cost==0&&sint==0
    Point=[];
else
    Point=getCrossPoint_CL(Circle1,[cost,sint,r,-inf,-inf,inf,inf]);
    for ii=size(Point,1):-1:1   
        if abs(norm(Point(ii,:)-[x2,y2])-abs(r2))>1e-12
            Point(ii,:)=[];
        end
    end 
end
end
%获取线段与圆交点- - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function Point=getCrossPoint_CL(Circle,Line)
cost=Line(1);sint=Line(2);
x0=Circle(1);y0=Circle(2);
R=Circle(3);r=Line(3);

if Line(1)~=0
    a=((sint/cost)^2+1);
    b=-2*((sint/cost)*(r/cost-x0)+y0);
    c=(r/cost-x0)^2+y0^2-R^2;
    if b^2-4*a*c<0
        Point=[];
    elseif b^2-4*a*c==0
        y=-b/2/a;
        x=-(sint/cost)*y+(r/cost);
        Point=[x,y];
    else
        y1=(-b+sqrt(b^2-4*a*c))/2/a;
        y2=(-b-sqrt(b^2-4*a*c))/2/a;
        x1=-(sint/cost)*y1+(r/cost);
        x2=-(sint/cost)*y2+(r/cost);
        Point=[x1,y1;x2,y2];  
    end
else
    a=((cost/sint)^2+1);
    b=-2*((cost/sint)*(r/sint-y0)+x0);
    c=(r/sint-y0)^2+x0^2-R^2;
    if b^2-4*a*c<0
        Point=[];
    elseif b^2-4*a*c==0
        x=-b/2/a;
        y=-(cost/sint)*x+(r/sint);
        Point=[x,y];
    else
        x1=(-b+sqrt(b^2-4*a*c))/2/a;
        x2=(-b-sqrt(b^2-4*a*c))/2/a;
        y1=-(cost/sint)*x1+(r/sint);
        y2=-(cost/sint)*x2+(r/sint);
        Point=[x1,y1;x2,y2];  
    end
end
for ii=size(Point,1):-1:1
    if ~pointInLine(Line,Point(ii,:))
        Point(ii,:)=[];
    end
end
end
%判断点是否在线段上- - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function Bool=pointInLine(Line,Point)
    XLim=sort([Line(4),Line(6)]);
    YLim=sort([Line(5),Line(7)]);
    if Point(1)<=XLim(2)&&Point(1)>=XLim(1)&&Point(2)<=YLim(2)&&Point(2)>=YLim(1)
        Bool=true;
    else
        Bool=false;
    end
end
%判断点到点集合内最近的点- - - - - - - - - - - - - - - - - - - - - - - - - 
function Point=getClosest(pointSet,Point)
    Dis=sqrt(sum((pointSet-Point).^2,2));
    coe1=Dis==min(Dis);
    coe2=Dis<=0.15;
    coe3=coe1&coe2;
    Point=pointSet(coe3,:);
    if ~isempty(Point)
        Point=Point(1,:);
    end
end
%画点- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function setPoint(Point,flag)
    [~,coe2,~]=intersect(pointSet_forDraw,Point,'rows');
    if nargin==1  
        if isempty(coe2)
            pointSet_forDraw=[pointSet_forDraw;Point];
            if isempty(PointNum)
                PointNum=1;
            else
                PointNum=[PointNum;max(PointNum)+1];
            end
            PHdl.(['n',num2str(PointNum(end))])=scatter3(OriPa_Axes,Point(1),Point(2),1,PointWidth_,'filled','CData',PointColor_);
        else
            PHdl.(['n',num2str(PointNum(coe2))]).SizeData=PointWidth_;
            PHdl.(['n',num2str(PointNum(coe2))]).CData=PointColor_;
        end
    else
        if ~isempty(coe2)
            delete(PHdl.(['n',num2str(PointNum(coe2))]));
            PointNum(coe2)=[];
            pointSet_forDraw(coe2,:)=[];
        end
    end
end
%计算直线- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function [Line,p1,p2]=getLineL(points)
    [~,sort1]=sort(points(:,2));
    points=points(sort1,:);
    [~,sort2]=sort(points(:,1));
    points=points(sort2,:);
    p1=points(1,:);
    p2=points(2,:);
    R=abs(det([p2-p1;p1]))/norm(p2-p1);
    if R~=0
        coe=[p1;p2]\[R;R];
        Line=[coe(1),coe(2),R,p1,p2];
    else
        v=p2-p1;
        v=[v(2),-v(1)]/norm(v);
        Line=[v,R,p1,p2];
    end
end
%画线- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function setLine(Line,p1,p2)
    [~,coe2,~]=intersect(LineSet(:,4:7),[p1,p2],'rows');
    if isempty(coe2)
        for ii=1:size(LineSet,1)
            Point=getCrossPoint_LL(LineSet(ii,:),Line);
            if ~isempty(Point)
                PointSet=[PointSet;Point];
                PointSet=unique(PointSet,'rows');
            end
        end
        LineSet=[LineSet;Line];
        if isempty(LineNum)
            LineNum=1;
        else
            LineNum=[LineNum;max(LineNum)+1];
        end
        LHdl.(['n',num2str(LineNum(end))])=plot(OriPa_Axes,[p1(1),p2(1)],[p1(2),p2(2)],'LineWidth',LineWidth_,'Color',LineColor_,'LineStyle',LineType_);
    else
        LHdl.(['n',num2str(LineNum(end))]).LineWidth=LineWidth_;
        LHdl.(['n',num2str(LineNum(end))]).Color=LineColor_;
        LHdl.(['n',num2str(LineNum(end))]).LineStyle=LineType_;
    end
    for ii=1:size(CircleSet,1)
        Points=getCrossPoint_CL(CircleSet(ii,:),Line);
        if ~isempty(Points)
            PointSet=[PointSet;Points];
            PointSet=unique(PointSet,'rows');
        end
    end
end
%删除线- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function deleteLine(p1,p2)
    [~,coe2,~]=intersect(LineSet(:,4:7),[p1,p2],'rows');
    if ~isempty(coe2)
        delete(LHdl.(['n',num2str(LineNum(coe2))]));
        LineNum(coe2)=[];
        LineSet(coe2,:)=[];
    end
end
%圆- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function setCircle(O,R)
    [~,coe2,~]=intersect(CircleSet,[O,R],'rows');
    if isempty(coe2)
        for ii=1:size(CircleSet,1)
            Points=getCrossPoint_CC(CircleSet(ii,:),[O,R]);
            if ~isempty(Points)
                PointSet=[PointSet;Points];
                PointSet=unique(PointSet,'rows');
            end
        end
        CircleSet=[CircleSet;[O,R]];
        if isempty(CircleNum)
            CircleNum=1;
        else
            CircleNum=[CircleNum;max(CircleNum)+1];
        end
        CHdl.(['n',num2str(CircleNum(end))])=plot(OriPa_Axes,cos(theta).*R+O(1),sin(theta).*R+O(2),'LineWidth',LineWidth_,'Color',LineColor_,'LineStyle',LineType_);
    else
        CHdl.(['n',num2str(CircleNum(end))]).LineWidth=LineWidth_;
        CHdl.(['n',num2str(CircleNum(end))]).Color=LineColor_;
        CHdl.(['n',num2str(CircleNum(end))]).LineStyle=LineType_;
    end
    for ii=1:size(LineSet,1)
        Points=getCrossPoint_CL([O,R],LineSet(ii,:));
        if ~isempty(Points)
            PointSet=[PointSet;Points];
            PointSet=unique(PointSet,'rows');
        end
    end
end
%删除圆- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function deleteCircle(O,R)
    coe1=sum((CircleSet-[O,R]).^2,2);
    coe2=coe1<1e-9;
    if any(coe2)
        coe3=find(coe1==min(coe1));
        delete(CHdl.(['n',num2str(CircleNum(coe3))]));
        CircleNum(coe3)=[];
        CircleSet(coe3,:)=[];
    end
%     if ~isempty(coe2)
%         delete(CHdl.(['n',num2str(CircleNum(coe2))]));
%         CircleNum(coe2)=[];
%         CircleSet(coe2,:)=[];
%     end
end

%计算与边缘交点- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function [p3,p4]=getEdgePoint(p1,p2)
    v1=p2-p1;
    coe11=10.*(v1./abs(v1));
    coe12=coe11-p1;
    coe13=coe12./v1;
    p3=p1+min(coe13).*v1;
    v2=p1-p2;
    coe21=10.*(v2./abs(v2));
    coe22=coe21-p2;
    coe23=coe22./v2;
    p4=p2+min(coe23).*v2;
end


%==========================================================================
%隐藏属性面板制作>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>||
%==========================================================================
OriPaMenu=uimenu(OriPa_Fig);
OriPaMenu.Text='SETUP';

OriPaMenu_1=uimenu(OriPaMenu);
OriPaMenu_1.Text='display attribute';
set(OriPaMenu_1,'MenuSelectedFcn',@MenuSelected)

function MenuSelected(~,obj)
    selectedMenu=obj.Source;
    switch 1
        case strcmp(selectedMenu.Text,'display attribute')
            selectedMenu.Text='hidden attribute';
            OriPa_Fig.Position=OriPa_Fig.Position+[0 0 400 0];
        case strcmp(selectedMenu.Text,'hidden attribute')
            selectedMenu.Text='display attribute';
            OriPa_Fig.Position=OriPa_Fig.Position+[0 0 -400 0];
    end
end
OriPa_Fig.AutoResizeChildren = 'off';


display_Axes=uiaxes('Parent',OriPa_Fig);
display_Axes.Position=[800,200,380,410];
display_Axes.XLim=[0,380];
display_Axes.YLim=[0,410];
display_Axes.XTick=[];
display_Axes.YTick=[];
display_Axes.XColor='none';
display_Axes.YColor='none';
display_Axes.BackgroundColor=[1 1 1];
display_Axes.XTickLabel={};
display_Axes.YTickLabel={};
display_Axes.Toolbar.Visible='off';
hold(display_Axes,'on');

text(display_Axes,10,400,'LineWidth','FontName','Cambria','FontSize',21);
for i=1:9
    plot(display_Axes,[10,150],[370 370]-18*(i-1),'Color',[0.2 0.2 0.2],'LineWidth',i.*0.5)
    text(display_Axes,160,370-18*(i-1),num2str(i*0.5),'FontName','Cambria','FontSize',15);
end
text(display_Axes,210,400,'LineStyle','FontName','Cambria','FontSize',21);

lt={'-';'--';':';'-.'};
lt2={'(-)';'(--)';'(:)';'(-.)'};
for i=1:4
    plot(display_Axes,[210,330],[370 370]-17*(i-1),'Color',[0.2 0.2 0.2],'LineWidth',1,'LineStyle',lt{i})
    text(display_Axes,340,370-17*(i-1),lt2{i},'FontName','Cambria','FontSize',12);
end

for i=1:4
    plot(display_Axes,[210,330],[280 280]-17*(i-1),'Color',[0.2 0.2 0.2],'LineWidth',2.5,'LineStyle',lt{i})
    text(display_Axes,340,280-17*(i-1),lt2{i},'FontName','Cambria','FontSize',12,'FontWeight','bold');
end

text(display_Axes,10,180,'Point/Line Color','FontName','Cambria','FontSize',21);

ColorList=[0.74 0.45 0.54;
    0.93 0.68 0.62;
    0.55 0.78 0.71;
    0.47 0.80 0.80;
    0.31 0.58 0.80;
    0.80 0.59 0.80];
ColorList2={'#BC748A';
    '#ECAD9E';
    '#8CC7B5';
    '#79CDCD';
    '#4F94CD';
    '#CD96CD';};
for i=1:6
    fill(display_Axes,[10 130 130 10],[140 140 160 160]-28*(i-1),ColorList(i,:))
    text(display_Axes,145,150-28*(i-1),ColorList2{i},'FontName','Cambria','FontSize',16);
end

text(display_Axes,240,180,'PointSize','FontName','Cambria','FontSize',21);
for i=1:5
    scatter(display_Axes,250,150-(i-1)*34,20+10*i,'filled','CData',[0.4 0.4 0.4])
    scatter(display_Axes,310,150-(i-1)*34,20+10*(i+5),'filled','CData',[0.4 0.4 0.4])
    text(display_Axes,260,150-(i-1)*34,num2str(20+10*i),'FontName','Cambria','FontSize',15);
    text(display_Axes,320,150-(i-1)*34,num2str(20+10*(i+5)),'FontName','Cambria','FontSize',15);
end

% LineColor_=[0 0.4470 0.7410];LineWidth_=2;LineType_='-';
% PointColor_=[0.5843 0.2157 0.2078];PointWidth_=55;

uilabel('parent',OriPa_Fig,'Text','  LineWidth','FontName','Cambria','FontWeight','bold',...
    'FontSize',15,'BackgroundColor',[0.31 0.58 0.80],'position',[815,135,85,30],'FontColor',[1 1 1]);
NumericLW=uispinner(OriPa_Fig,'Value',2,'limit',[0.1 15],'FontName','Cambria','Step',0.1,...
    'ValueDisplayFormat','%.1f','FontSize',14,'ValueChangedFcn',@LWset,'position',[905,135,60,30]);
function LWset(~,~)
    tempV=NumericLW.Value;
    tempV=round(tempV*10)./10;
    NumericLW.Value=tempV;
    LineWidth_=tempV;
end

uilabel('parent',OriPa_Fig,'Text','  PointSize','FontName','Cambria','FontWeight','bold',...
    'FontSize',15,'BackgroundColor',[0.31 0.58 0.80],'position',[815,95,85,30],'FontColor',[1 1 1]);
NumericPS=uispinner(OriPa_Fig,'Value',55,'limit',[10 150],'FontName','Cambria','Step',5,...
    'ValueDisplayFormat','%.0f','FontSize',14,'ValueChangedFcn',@PSset,'position',[905,95,60,30]);
function PSset(~,~)
    tempV=NumericPS.Value;
    tempV=round(tempV);
    NumericPS.Value=tempV;
    PointWidth_=tempV;
end

uilabel('parent',OriPa_Fig,'Text','  LineStyle','FontName','Cambria','FontWeight','bold',...
    'FontSize',15,'BackgroundColor',[0.31 0.58 0.80],'position',[815,55,85,30],'FontColor',[1 1 1]);
NumericLS=uidropdown('parent',OriPa_Fig);
NumericLS.Items={'  (-)';'  (--)';'  (:)';'  (-.)'};
NumericLS.ValueChangedFcn=@setLS;
NumericLS.Position=[905,55,55,30];
function setLS(~,~)
    tempV=NumericLS.Value;
    tempV=tempV(4:end-1);
    LineType_=tempV;
end


uilabel('parent',OriPa_Fig,'Text','  Line Color','FontName','Cambria','FontWeight','bold',...
    'FontSize',15,'BackgroundColor',[0.31 0.58 0.80],'position',[975,135,85,30],'FontColor',[1 1 1]);
editfieldLC=uieditfield(OriPa_Fig,'Value','#0072BD','FontName','Cambria','HorizontalAlignment','center',...
    'FontSize',16,'ValueChangedFcn',@setLC,'Position',[1057,135,85,30]);%0.00 0.45 0.74


uilabel('parent',OriPa_Fig,'Text','  PointColor','FontName','Cambria','FontWeight','bold',...
    'FontSize',15,'BackgroundColor',[0.31 0.58 0.80],'position',[975,95,85,30],'FontColor',[1 1 1]);
editfieldPC=uieditfield(OriPa_Fig,'Value','#953735','FontName','Cambria','HorizontalAlignment','center',...
    'FontSize',16,'ValueChangedFcn',@setPC,'Position',[1057,95,85,30]);%0.58 0.22 0.21

display2_Axes=uiaxes('Parent',OriPa_Fig);
display2_Axes.Position=[1143,90,40,80];
display2_Axes.XLim=[0,1];
display2_Axes.YLim=[0,2];
display2_Axes.XTick=[];
display2_Axes.YTick=[];
display2_Axes.XColor='none';
display2_Axes.YColor='none';
display2_Axes.BackgroundColor=[1 1 1];
display2_Axes.XTickLabel={};
display2_Axes.YTickLabel={};
display2_Axes.Toolbar.Visible='off';
hold(display2_Axes,'on');

displayLCHdl=fill(display2_Axes,cos(0:0.1:2*pi+0.1).*0.4.*0.7+0.3,sin(0:0.1:2*pi+0.1).*0.37.*0.7+1.55,[0.00 0.45 0.74],'EdgeColor','none');
displayPCHdl=fill(display2_Axes,cos(0:0.1:2*pi+0.1).*0.4.*0.7+0.3,sin(0:0.1:2*pi+0.1).*0.37.*0.7+0.45,[0.58 0.22 0.21],'EdgeColor','none');
function setLC(~,~)
    tempV=editfieldLC.Value;
    tempV=sixteen2ten(tempV);
    if ~isnan(tempV)
        displayLCHdl.FaceColor=tempV./255;
        LineColor_=tempV./255;
    end
end

function setPC(~,~)
    tempV=editfieldPC.Value;
    tempV=sixteen2ten(tempV);
    if ~isnan(tempV)
        displayPCHdl.FaceColor=tempV./255;
        PointColor_=tempV./255;
    end
end


function num=sixteen2ten(string)
    exchange_list='0123456789ABCDEF#';
    num=zeros(1,3);
    if all(ismember(string,exchange_list))
        for ii=1:3
            tempCoe1=find(ismember(exchange_list,string(ii*2))==1)-1;
            tempCoe2=find(ismember(exchange_list,string(ii*2+1))==1)-1;
            num(ii)=16*tempCoe1+tempCoe2;
        end
    else
        num=nan;
    end
end

uibutton(OriPa_Fig,'Text','CLEAR ALL','BackgroundColor',[0.59 0.71 0.84],'FontColor',[1 1 1],...
    'FontWeight','bold','Position',[975,55,90,30],'FontName','Cambria','FontSize',15,'ButtonPushedFcn',@clearAllFcn);
    function clearAllFcn(~,~)
        for ii=length(PointNum):-1:1
            delete(PHdl.(['n',num2str(PointNum(ii))]));
            PointNum(ii)=[];
            pointSet_forDraw(ii,:)=[];
        end
        for ii=length(LineNum):-1:1
            delete(LHdl.(['n',num2str(LineNum(ii))]));
            LineNum(ii)=[];
            LineSet(ii,:)=[];
        end
        for ii=length(CircleNum):-1:1
            delete(CHdl.(['n',num2str(CircleNum(ii))]));
            CircleNum(ii)=[];
            CircleSet(ii,:)=[];
        end
        PointSet=[0 0];
        PointSet(1,:)=[];    
    end
uibutton(OriPa_Fig,'Text','SAVE IMAGE','BackgroundColor',[0.59 0.71 0.84],'FontColor',[1 1 1],...
    'FontWeight','bold','Position',[1075,55,95,30],'FontName','Cambria','FontSize',15,'ButtonPushedFcn',@saveImageFcn);
    function saveImageFcn(~,~)
        try
        new_fig=figure('units','pixels',...
            'position',[0 0 620 620],...
            'Numbertitle','on',...
            'menubar','none',...
            'visible','off',...
            'resize','off',...
            'color',[1 1 1]);
        new_axes=axes('Units','pixels',...
            'parent',new_fig,...
            'PlotBoxAspectRatio',[1 1 1],...
            'Position',[10 10 600 600],...
            'Box','on', ...
            'XLim',[-10,10],...
            'YLim',[-10,10], ...
            'XTickLabels',{},...
            'YTickLabels',{},...
            'XTick',-10:10,'YTick',-10:10,...
            'XGrid','on','YGrid','on');
        hold(new_axes,'on')
        for ii=1:length(PointNum)
            scatter3(new_axes,PHdl.(['n',num2str(PointNum(ii))]).XData,...
                PHdl.(['n',num2str(PointNum(ii))]).YData,...
                1,PHdl.(['n',num2str(PointNum(ii))]).SizeData,'filled','CData',...
                PHdl.(['n',num2str(PointNum(ii))]).CData);
        end
        for ii=1:length(LineNum)
            plot(new_axes,LHdl.(['n',num2str(LineNum(ii))]).XData,...
                LHdl.(['n',num2str(LineNum(ii))]).YData,...
                'LineWidth',LHdl.(['n',num2str(LineNum(ii))]).LineWidth,...
                'Color',LHdl.(['n',num2str(LineNum(ii))]).Color,...
                'LineStyle',LHdl.(['n',num2str(LineNum(ii))]).LineStyle);
        end
        for ii=1:length(CircleNum)
            plot(new_axes,CHdl.(['n',num2str(CircleNum(ii))]).XData,...
                CHdl.(['n',num2str(CircleNum(ii))]).YData,...
                'LineWidth',CHdl.(['n',num2str(CircleNum(ii))]).LineWidth,...
                'Color',CHdl.(['n',num2str(CircleNum(ii))]).Color,...
                'LineStyle',CHdl.(['n',num2str(CircleNum(ii))]).LineStyle);
        end
        [filename,pathname]=uiputfile({'*.*';'*.jpg';'*.tif';'*.bmp';'*.png'});
        saveas(new_fig,[pathname,filename]);
        delete(new_fig)
        catch
        end
    end




end