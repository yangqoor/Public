% ����������㣬�������ͼ��
pnt=[1 2;3 4;7 5];
scatter(pnt(:,1),pnt(:,2),'filled')
hold on

% �������������Բ
[Func,~,~]=getCircle(pnt(:,1),pnt(:,2));
fimplicit(Func,[-0 15 -10 6],'LineWidth',2,'Color',[114,146,184]./255)

% ����һ�£�����ɾ��
decoAx()