% ������ĸ��㣬�������ͼ��
pnt=[0,0,1;1,1,6;1,3,4;9,6,11];
scatter3(pnt(:,1),pnt(:,2),pnt(:,3),'filled')
hold on

% ������ĺͰ뾶,�����������mesh����
[~,Mu,R]=getBall(pnt(:,1),pnt(:,2),pnt(:,3));
[X,Y,Z]=sphere(40);
mesh(X.*R+Mu(1),Y.*R+Mu(2),Z.*R+Mu(3),'FaceColor','flat','FaceAlpha',.3)

% ����һ�£�����ɾ��
decoAx()