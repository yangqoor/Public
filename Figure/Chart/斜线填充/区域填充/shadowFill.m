function SF=shadowFill(X,Y,theta,num,varargin)
% @author : slandarer
% 公众号  : slandarer随笔
% 知乎    : hikari
if theta>pi/2||theta<-pi/2
    error('Inner theta should be in range of [-pi/2,pi/2]');
end
% 基础属性获取
ax=gca;hold on;
try
pshape=polyshape(X,Y);
catch
end
XYmin=[min(X),min(Y)];
XYmax=[max(X),max(Y)];
diffY=max(Y)-min(Y);

% 获取阴影线数值
if abs(theta)<eps
    YY=linspace(XYmin(2),XYmax(2),num);
    tXX=zeros(3,num);tYY=zeros(3,num);
    for i=1:num
        [in,~]=intersect(pshape,[XYmin(1),YY(i);XYmax(2),YY(i)]);
        if ~isempty(in)
            tXX(:,i)=[in(1,1);in(end,1);nan];
            tYY(:,i)=[in(1,2);in(end,2);nan];
        else
            tXX(:,i)=[nan;nan;nan];
            tYY(:,i)=[nan;nan;nan];
        end
    end
else
    cott=cot(theta);
    XX1=linspace(XYmin(1)-cott.*diffY,XYmax(1),num);
    XX2=linspace(XYmin(1),XYmax(1)+cott.*diffY,num);
    tXX=zeros(3,num);tYY=zeros(3,num);
    for i=1:num
        [in,~]=intersect(pshape,[XX1(i),XYmin(2);XX2(i),XYmax(2)]);
        if ~isempty(in)
            tXX(:,i)=[in(1,1);in(end,1);nan];
            tYY(:,i)=[in(1,2);in(end,2);nan];
        else
            tXX(:,i)=[nan;nan;nan];
            tYY(:,i)=[nan;nan;nan];
        end
    end
end
% 绘制阴影
SF=plot(ax,tXX(:),tYY(:),'LineWidth',.5,'Color',[0,0,0],varargin{:},'Tag','shadowFill');
end