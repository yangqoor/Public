function Hdl=violinChart(ax,X,Y,FaceColor,width)
% @author slandarer
% Hdl: ���ص�ͼ�ζ������ṹ��
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Hdl.F_density(i)   | patch   | ���ܶȷֲ�
% Hdl.F_outlier(i)   | scatter | ��Ⱥֵ��
% Hdl.F_range95(i)   | line    | ȥ����Ⱥֵ������ֵ����Сֵ
% Hdl.F_quantile(i)  | patch   | �ķ�λ����
% Hdl.F_medianLine(i)| line    | ��λ��
%
% Hdl.F_legend       | patch   | ��������legendͼ����ͼ�ζ���
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% ��ʹ�����·�ʽ����ͼ����
% Hdl1=violinChart(ax,X,Y,... ...)
% Hdl2=violinChart(ax,X,Y,... ...)
% ... ...
% legend([Hdl1,Hdl2,... ...],{Name1,Name2,...})
% ===========================================================
% ����Ϊʹ��ʵ�����룺
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% X1=[1:2:7,13];
% Y1=randn(100,5)+sin(X1);
% X2=2:2:10;
% Y2=randn(100,5)+cos(X2);
% 
% Hdl1=violinChart(gca,X1,Y1,[0     0.447 0.741],0.5);
% Hdl2=violinChart(gca,X2,Y2,[0.850 0.325 0.098],0.5);
% legend([Hdl1.F_legend,Hdl2.F_legend],{'randn+sin(x)','randn+cos(x)'});

if nargin<5
    width=0.4;
end

if ~isempty(ax)
else
    ax=gca;
end
hold(ax,'on');

oriX=X;
X=unique(X);
sep=min(diff(X));
if isempty(sep)
    sep=1;
end

for i=1:length(X)
    if length(oriX)==numel(Y)
        tY=Y(oriX==X(i));
    else
        tY=Y(:,i);
    end
    [f,yi]=ksdensity(tY);
    Hdl.F_density(i)=fill([f,-f(end:-1:1)].*sep.*width+X(i),[yi,yi(end:-1:1)],FaceColor);
    
    outliBool=isoutlier(tY,'quartiles');
    outli=tY(outliBool);
    Hdl.F_outlier(i)=scatter(repmat(X(i),[length(outli),1]),outli,20,'filled',...
                    'CData',[1 1 1],'MarkerEdgeColor','none');
    nY=tY(~outliBool);
    Hdl.F_range95(i)=plot([X(i),X(i)],[min(nY),max(nY)],'k','lineWidth',1);
    
    qt25=quantile(tY,0.25);
    qt75=quantile(tY,0.75);
    
    Hdl.F_quantile(i)=fill(X(i)+0.6.*sep.*width.*[-1 1 1 -1].*max(f),...
                    [qt25,qt25,qt75,qt75],[1 1 1],...
                    'EdgeColor',[0 0 0]);
                
    med=median(tY);
    Hdl.F_medianLine(i)=plot(X(i)+0.6.*sep.*width.*[-1 1].*max(f),[med,med],'LineWidth',3,...
                    'Color',[0 0 0]);
end

Hdl.F_legend=Hdl.F_density(1);
end