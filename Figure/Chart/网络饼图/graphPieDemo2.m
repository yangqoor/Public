% 随机生成邻接矩阵
A=rand(16)>.8;
A=(A+A')./2;
A(~~eye(size(A)))=0;
R=rand(3,16);
% 自定义了点配色RGB 0-1
CList=[0.3686    0.5059    0.6745
    0.5608    0.6588    0.4784
    0.7490    0.3804    0.4157
    0.9059    0.8235    0.0078
    0.4902    0.3255    0.1608
    0.9569    0.5843    0.2196
    0.4000    0.8039    0.6667
    0.8157    0.4392    0.7255
    0.5961    0.9843    0.5961
    0.9882    0.6392    0.7176];
% 使用MATLAB自带函数构建网络
fig1=figure();
G=graph(A);
GHdl=plot(G,'Layout','circle','Center',1);
S=G.Edges.EndNodes(:,1).';
T=G.Edges.EndNodes(:,2).';
X=GHdl.XData;
Y=GHdl.YData;
XY=[X(:),Y(:)];
close(fig1)

% 新图窗创建及坐标区域修饰
fig2=figure('Units','normalized','Position',[.2,.2,.4,.6]);
ax=gca;
ax.DataAspectRatio=[1,1,1];
ax.XColor='none';
ax.YColor='none';
L=pdist2(XY,XY);
L(~~eye(size(L,1)))=inf;
L=min(min(L)).*.3;

% 重绘网络图
hold on
LX=[X(S);X(T);S.*nan];
LY=[Y(S);Y(T);S.*nan];
plot(LX(:),LY(:),'LineWidth',1,'Color','k');

% 绘制饼图
R=R./sum(R,1);
Theta=cumsum([zeros(1,size(R,2));R]).*2.*pi;
Tt01=linspace(0,1,50);
for i=1:size(R,2)
    for k=1:size(R,1)
        Tt=(Theta(k+1,i)-Theta(k,i)).*Tt01+Theta(k,i);
        PHdl=fill([X(i),cos(Tt).*L+X(i)],[Y(i),sin(Tt).*L+Y(i)],CList(k,:),'EdgeColor','w','LineWidth',1);
        if i==1,PltHdl(k)=PHdl;end
    end
end

% 绘制图例
lgdHdl=legend(PltHdl,'Box','off','FontName','Times New Roman',...
    'FontSize',13,'Orientation','horizontal','Location','best');
lgdHdl.ItemTokenSize=[14,14];