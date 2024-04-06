% -----------------------------------------------------+
% @author  | slandarer                                 |
% 公众号   | slandarer随笔                              |
% 知乎     | slandarer                                 |
% -----------------------------------------------------+
% 复刻自   | www.nature.com/articles/s41586-021-03922-4 |
% -----------------------------------------------------+

figure('Name','nature sankey demo','Units','normalized','Position',[.05,.2,.9,.56])
clc;clear;

%% 配色 ===================================================================
CList1=[233,163,117; 150,209,224; 78 ,115,180]./255;
CList2=[149, 77, 85; 182, 85, 90; 208, 91, 94;
        208, 91, 94; 245,124,112; 252,150,128;
        252,173,151; 253,196,176; 253,217,203;
        254,236,228; 230,230,230]./255;
%% 随意构造数据 ============================================================
% rng(5)
% SourceValue=[60,40,30];
% LayerNum=[3,10,10,10,10,10,6,1];
% links{1,3}='';
% for k=1
%     TargetValue=zeros(1,LayerNum(k+1));
%     for i=1:LayerNum(k)
%         tValue=randi([1,13],[1,LayerNum(k+1)]);
%         tValue=tValue./sum(tValue).*SourceValue(i);
%         for j=1:LayerNum(k+1)
%             TargetValue(j)=TargetValue(j)+tValue(j);
%             if tValue(j)>eps
%                 tLen=size(links,1);
%                 links{tLen+1,1}=[char(64+k),num2str(i)];
%                 links{tLen+1,2}=[char(64+k+1),num2str(j)];
%                 links{tLen+1,3}=tValue(j);
%             end
%         end
%     end
%     SourceValue=TargetValue;
% end
% links(1,:)=[];
% tResidual=0;
% for k=2:5
%     [~,tindex]=sort(rand([1,10]));
%     for i=1:10
%         tLen=size(links,1);
%         TargetValue(tindex(i))=SourceValue(i);
%         links{tLen+1,1}=[char(64+k),num2str(i)];
%         links{tLen+1,2}=[char(64+k+1),num2str(tindex(i))];
%         links{tLen+1,3}=SourceValue(i);
%     end
%     for i=1:10
%         tLen=size(links,1);
%         links{tLen+1,1}=['Residual-',char(64+k)];
%         links{tLen+1,2}=[char(64+k+1),num2str(tindex(i))];
%         tValue=rand([1,1])*20./(k.^1);
%         links{tLen+1,3}=tValue;
%         if k==2,tResidual=tResidual+tValue;end
%         if k==5,TargetValue(i)=TargetValue(i)+tValue;end
%     end
%     SourceValue=TargetValue;
% end
% k=1;tValue=randi([1,13],[1,3]);
% for i=1:3
%     tLen=size(links,1);
%     links{tLen+1,1}=[char(64+k),num2str(i)];
%     links{tLen+1,2}=['Residual-',char(64+k+1)];
%     links{tLen+1,3}=tValue(i)./sum(tValue).*tResidual;
% end
% for k=6
%     TargetValue=zeros(1,LayerNum(k+1));
%     for i=1:LayerNum(k)
%         tValue=randi([1,13],[1,LayerNum(k+1)]);
%         tValue=tValue./sum(tValue).*SourceValue(i);
%         for j=1:LayerNum(k+1)
%             TargetValue(j)=TargetValue(j)+tValue(j);
%             if tValue(j)>eps
%                 tLen=size(links,1);
%                 links{tLen+1,1}=[char(64+k),num2str(i)];
%                 links{tLen+1,2}=[char(64+k+1),num2str(j)];
%                 links{tLen+1,3}=tValue(j);
%             end
%         end
%     end
%     SourceValue=TargetValue;
% end
% k=7;
% for i=1:LayerNum(end-1)
%     tLen=size(links,1);
%     links{tLen+1,1}=[char(64+k),num2str(i)];
%     links{tLen+1,2}=' ';
%     links{tLen+1,3}=SourceValue(i);
% end
% save natureRandData.mat links
load('natureRandData.mat')

%% 绘图主要代码 ============================================================
% 创建桑基图对象(Create a Sankey diagram object)
SK=SSankey(links(:,1),links(:,2),links(:,3));

% 类似于向右侧对齐
SK.LayerOrder='reverse';

% 修改链接颜色渲染方式(Set link color rendering method)
% 'left'/'right'/'interp'(default)/'map'/'simple'
SK.RenderingMethod='left';  

% 修改对齐方式(Set alignment)
% 'up'/'down'/'center'(default)
SK.Align='center';

% 修改文本位置(Set Text Location)
% 'left'(default)/'right'/'top'/'center'/'bottom'
SK.LabelLocation='right';

% 设置缝隙占比(Separation distance proportion)
SK.Sep=[.08,.04,.02,.05,.05,.06,.07];

% 设置方块占比(Set the scale of blocks)
% BlockScale>0 & BlockScale<1
SK.BlockScale=.16;

% 设置颜色(Set color)
SK.ColorList=[
    CList1;
    CList2(1:11,:)
    CList2(1:11,:)
    CList2(1:11,:)
    CList2(1:11,:)
    CList2(1:10,:)
    CList2(1:6,:)
    CList2(1,:)
    ];

% 开始绘图(Start drawing)
SK.draw()
%% 修饰 ===================================================================

for i=1:SK.BN
    SK.setBlock(i,'EdgeColor',[1,1,1],'LineWidth',1)
end
FontCell={'FontSize',22,'FontName','Times New Roman','HorizontalAlignment','center','VerticalAlignment','bottom'};
for i=2:SK.LN-1
    text(i+SK.BlockScale/2,min(min(SK.LayerPos(:,3:4))),['H',num2str(i-1)],FontCell{:})
end
text(1+SK.BlockScale/2,min(min(SK.LayerPos(:,3:4))),'Input',FontCell{:})
text(8+SK.BlockScale/2,min(min(SK.LayerPos(:,3:4))),'OutCome',FontCell{:})



