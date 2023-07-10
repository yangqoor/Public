function [nX,nY,nZ]=isocurve3(X,Y,Z,f1,f2)
% 获取f1隐函数的三角面和三角顶点
V1=f1(X,Y,Z);
hel=isosurface(X,Y,Z,V1,0);
% 将f1获取的三角顶点带入f2求得数值
V2=f2(hel.vertices(:,1),hel.vertices(:,2),hel.vertices(:,3));
% 检查三个顶点的数值是否同时含有有大于0数值及小于0数值
mask=V2>0;
outcount=sum(mask(hel.faces),2);
cross=(outcount==2)|(outcount==1);
crossing_tris=hel.faces(cross,:);
% 通过旋转交换三个顶点次序，将小于0的点放在第一列
out_vert=mask(crossing_tris);
flip=sum(out_vert,2)==1;
out_vert(flip,:)=1-out_vert(flip,:);
ntri=size(out_vert,1);
overt=zeros(ntri,3);
for i=1:ntri
    v1i=find(~out_vert(i,:));
    v2i=1+mod(v1i,3);
    v3i=1+mod(v1i+1,3);
    overt(i,:)=crossing_tris(i,[v1i v2i v3i]);
end
% 类似于求重心
u=(-V2(overt(:,1)))./(V2(overt(:,2))-V2(overt(:,1)));
v=(-V2(overt(:,1)))./(V2(overt(:,3))-V2(overt(:,1)));
uverts=repmat((1-u),[1 3]).*hel.vertices(overt(:,1),:)+repmat(u,[1 3]).*hel.vertices(overt(:,2),:);
vverts=repmat((1-v),[1 3]).*hel.vertices(overt(:,1),:)+repmat(v,[1 3]).*hel.vertices(overt(:,3),:);
% 因为可能含有多条曲线，因此逐段连线
nX=nan(3,ntri);
nX(1,:)=uverts(:,1)';
nX(2,:)=vverts(:,1)';
nY=nan(3,ntri);
nY(1,:)=uverts(:,2)'; 
nY(2,:)=vverts(:,2)';
nZ=nan(3,ntri);
nZ(1,:)=uverts(:,3)';
nZ(2,:)=vverts(:,3)';
end