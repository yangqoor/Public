function U=dir_istoch(N)
global xx yy
% U - ��������������� (������); N - ����� ������ yy � ���������������� 

[p,e,t]=initmesh('pryamg');[p,e,t]=refinemesh('pryamg',p,e,t);
[p,e,t]=refinemesh('pryamg',p,e,t);
u=assempde('prya',p,e,t,1,0,'istok1');% ��������
uxy=tri2grid(p,t,u,xx,yy);
U=uxy(N,:);