% ������ĸ��㣬�������ͼ��
pnt=[0,0,1;1,1,6;1,3,4;9,6,11];
scatter3(pnt(:,1),pnt(:,2),pnt(:,3),'filled')
hold on

% ��ȡ������������fimplicit3������ά������
[Func,~,~]=getBall(pnt(:,1),pnt(:,2),pnt(:,3));
fimplicit3(Func,[-30,30],'MeshDensity',40,'EdgeColor','interp','FaceAlpha',.3)

% ����һ�£�����ɾ��
decoAx()