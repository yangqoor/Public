% ����������㣬�������ͼ��
pnt=[1 2;3 4;7 5];
scatter(pnt(:,1),pnt(:,2),'filled')
hold on

% ���Բ�ĺͰ뾶����Բ
[~,Mu,R]=getCircle(pnt(:,1),pnt(:,2));
t=linspace(0,2*pi,100);
plot(cos(t).*R+Mu(1),sin(t).*R+Mu(2),'LineWidth',2,'Color',[114,146,184]./255)

% ����һ�£�����ɾ��
decoAx()