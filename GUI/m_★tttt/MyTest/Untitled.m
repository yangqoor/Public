% figure;imshow(Arr(1:120,:),[]);
% 
% figure;imshow(B,[]);
% 
% load('mycolor.mat')
% map=colormap(newcolorbar);
% figure
% res0 = grs2rgb(Arr(1:120,:),map);
% % res0 = grs2rgb(B,map);
% res0 = im2uint8(res0);
% imshow(res0,[])

% new_B = uint8(B);
% h2=fspecial('average',3);
% bw1=medfilt2(new_B,[3,3]);
% bw1=imfilter(bw1,h2,'replicate');
% level = graythresh(bw1);
% bw3 = im2bw(bw1,level+0.501);
% se=strel('rectangle',[6,6]);
% bw3=imerode(bw3,se);

figure;imshow(bw3);
    
% figure;imshow(bw4);
% bw5 = bw4;
% 
bw6=imdilate(bw4,se);
figure;imshow(bw6);% 料线


% bw7 = bw5-bw6;

all_area = bwarea(bw4)
% LL=bwlabel(bw4);%L = bwlabel(BW,n)返回一个和BW大小相同的L矩阵,包含了标记了BW中每个连通区域的类别标签,这些标签的值为1、2、num(连通区域的个数)。n的值为4或8
% stats2=regionprops(LL,'Area');
% area = stats2.Area


[m,n] = size(bw4);
im_area = m*n;
k_ostu = all_area/im_area



bw7 = bwareaopen(bw4,120,8);%去除小面积
bw7=imdilate(bw7,strel('rectangle',[5,10]));
bw7=imerode(bw7,strel('rectangle',[5,10]));
bw7=imerode(bw7,strel('rectangle',[2,110]));
bw7=imdilate(bw7,strel('rectangle',[2,110]));
figure;imshow(bw7);% 干扰
% bw8 = imdilate(bw7,strel('rectangle',[3,1]));
im = bwperim(bw7);
figure;imshow(im);

hold on
L_noise = bwlabel(bw7);%L = bwlabel(BW,n)返回一个和BW大小相同的L矩阵,包含了标记了BW中每个连通区域的类别标签,这些标签的值为1、2、num(连通区域的个数)。n的值为4或8
B_noise  = bwboundaries(L_noise);%获取二值图中对象的轮廓，包括外部轮廓与内部边缘。
boundary_noise = B_noise{1};
% line(boundary_noise(:,2),boundary_noise(:,1) ,'Color','y','LineWidth',2);

bw6 = bw4-bw7;
figure;imshow(bw6);
bw6 = bwareaopen(bw6,120,4);%去除小面积
bw6=imerode(bw6,strel('disk',3,4));
bw6=imdilate(bw6,strel('disk',3,4));
bw6=imdilate(bw6,strel('rectangle',[1,5]));
bw6=imerode(bw6,strel('rectangle',[1,5]));
figure;imshow(bw6);
obj_area = bwarea(bw6);
k_obj = obj_area/im_area




gaorao = double(bw7);
bb = find (gaorao > 0);
gaorao(bb) = gaorao(bb)+100;
figure;imshow(gaorao);

all = liaoxian+gaorao;
figure;imshow(all);

r=1:120;
% thet=(ang_out+ang_in)*6/egn;
theta=linspace(-(90+ang_out)/180.0*pi,-(90-ang_in)/180.0*pi,egn);
[R,Theta]=meshgrid(r,theta);
% val=sin(R+Theta);%这里就是你的值。
% val = Arr((fs_out+1):(fs_out+120),:);%原val
val = Arr(1:120,:);
% val = double(all);%改动val
val = val';
max_val = max(max(val));

[X]=R.*cos(Theta)*0.09155+dist_out;
[Y]=abs(R.*sin(Theta)*0.09155)-zerodis;

figure;
ii = find(X<0);
val(ii) = zeros(size(ii));
surf(X,Y,val);%画右曲面
hold on
surf(-X,Y,val);%画左曲面
shading interp;%去除曲面网格
view(0,90);
grid on;%加坐标网格
hold on;

x_min = min(min(-X));
x_max = max(max(X));
y_min = min(min(Y));
y_max = max(max(Y));

xlin = linspace(x_min,x_max,egn);
ylin = linspace(y_min,y_max,egn);
[X1,Y1] = meshgrid(xlin,ylin);
val_zeros = zeros(size(X1));

surf(X1,Y1,val_zeros);
colormap parula
shading interp;%去除曲面网格
grid on;%加坐标网格
axis equal
axis([x_min x_max y_min y_max -inf inf])
set(gca,'XTick',[fix(x_min):1:fix(x_max)]);
view(0,90);
% axis off
set(gca,'YDir','reverse');

figure;
plot3(ax,abs(ay)-zerodis,az,'r-','MarkerSize',2,'linewidth',2)
axis equal
axis([x_min x_max y_min y_max -inf inf])
set(gca,'XTick',[fix(x_min):1:fix(x_max)]);
view(0,90);
% grid on;
set(gca,'YDir','reverse');
axis off
% fill([0 95 95 0],[0 0 50 50],'g','edgecolor','none','facealpha',0.87)