function axProjection3D(varargin)
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari


% 获取参数
if isa(varargin{1},'matlab.graphics.axis.Axes')
    ax=varargin{1};varargin(1)=[];
else
    ax=gca;
end
hold(ax,'on')
ax.XLim=ax.XLim;
ax.YLim=ax.YLim;
ax.ZLim=ax.ZLim;
state=upper(varargin{1});
if length(varargin)>1
    faceColor=varargin{2};
else
    faceColor=[.5,.5,.5];
end
[~,state,~]=intersect('XYZ',state);

% 记录子图形对象
ChildrenList(length(ax.Children))=ax.Children(end);
for n=1:length(ax.Children)
    ChildrenList(n)=ax.Children(n);
end
for n=length(ChildrenList):-1:1
    if strcmp(ChildrenList(n).Tag,'AP3D')
        ChildrenList(n)=[];
    end
end

% 绘制投影
minLim=[ax.XLim(2),ax.YLim(2),ax.ZLim(1)];
for i=1:length(state)
    ii=state(i);
    for n=1:length(ChildrenList)
        switch true
            % Patch对象投影 
            case isa(ChildrenList(n),'matlab.graphics.primitive.Patch')
            tobj=copyobj(ChildrenList(n),ax);
            tobj.Vertices(:,ii)=minLim(ii);
            tobj.FaceColor=faceColor;
            tobj.FaceAlpha=.5;
            tobj.EdgeColor=faceColor./5;
            tobj.EdgeAlpha=.9;
            tobj.Tag='AP3D';
            % Surface对象投影
            case isa(ChildrenList(n),'matlab.graphics.chart.primitive.Surface')||isa(ChildrenList(n),'matlab.graphics.primitive.Surface')
            tobj=copyobj(ChildrenList(n),ax);
            switch ii
                case 1,tobj.XData(:,:)=minLim(ii);
                case 2,tobj.YData(:,:)=minLim(ii);
                case 3,tobj.ZData(:,:)=minLim(ii);
            end
            tobj.FaceColor=faceColor;
            tobj.FaceAlpha=.5;
            tobj.EdgeColor=faceColor./5;
            tobj.EdgeAlpha=.9;
            tobj.Tag='AP3D';
            % Line对象投影
            case isa(ChildrenList(n),'matlab.graphics.chart.primitive.Line')||isa(ChildrenList(n),'matlab.graphics.primitive.Line')
            tobj=copyobj(ChildrenList(n),ax);
            switch ii
                case 1,tobj.XData(:,:)=minLim(ii);
                case 2,tobj.YData(:,:)=minLim(ii);
                case 3,tobj.ZData(:,:)=minLim(ii);
            end
            tobj.Color=[faceColor,.5];
            tobj.Tag='AP3D';
            % 三维参数化曲线
            case isa(ChildrenList(n),'matlab.graphics.function.ParameterizedFunctionLine')
            tobj=copyobj(ChildrenList(n),ax);
            switch ii
                case 1,tobj.XFunction=@(t)t.*0+minLim(ii);
                case 2,tobj.YFunction=@(t)t.*0+minLim(ii);
                case 3,tobj.ZFunction=@(t)t.*0+minLim(ii);
            end
            tobj.Color=[faceColor,.5];
            tobj.Tag='AP3D';
            % 三维参数化曲面
            case isa(ChildrenList(n),'matlab.graphics.function.ParameterizedFunctionSurface')
            tobj=copyobj(ChildrenList(n),ax);
            switch ii
                case 1,tobj.XFunction=minLim(ii);
                case 2,tobj.YFunction=minLim(ii);
                case 3,tobj.ZFunction=minLim(ii);
            end
            tobj.FaceColor=faceColor;
            tobj.FaceAlpha=.5;
            tobj.EdgeColor=faceColor./5;
            tobj.Tag='AP3D';
        end
    end
end
end