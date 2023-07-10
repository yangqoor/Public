%%
%fig0中，海参0时刻图像用这个程序
clc;clear;
yuantu=imread('001.bmp');
huitu=rgb2gray(yuantu);
subplot(2,2,1),imtool(huitu);%用来测出大致灰度范围
%%
bw=roicolor(huitu,0,100);%在灰度0~100，内为roi区域，其他全为背景    %这句很关键，对不同图像要修改这句
%%
% subplot(2,3,1),subimage(huitu);colorbar('veit');
% subplot(2,3,2),subimage(bw);
% bw=im2uint8(bw)/255;%如果不除以255，则是在0~255，逻辑0变为0,1变为255
% % hetu=immultiply(huitu,bw);%如要目标的灰度图像的话，可选这句
% %%
% %形态学处理，主要是为了祛除边缘特别毛刺区域
% SE=strel('disk',2);%strel函数生成结构元素对象，为形态学处理做准备
% biyunsuan=imclose(bw,SE);
% [h,w]=size(huitu);
% quchu=ones(h,w);quchu(h/2:end,1:end)=0;beijing=im2uint8(quchu)/255;%制造出一个区域把目标之外的区域祛除。
% mubiao=immultiply(beijing,biyunsuan);%显示祛除背景后纯目标（灰度）图像
% subplot(2,3,3);subimage(mubiao);
% [level EM] = graythresh(mubiao);%EM为对应的矩阵，level是graythresh算出的阈值
% erzhi=im2bw(mubiao,level);%阈值范围0~1，默认0.5，故先用函数获取阈值level.
% biaoji=bwlabel(erzhi,8);
% bianyuan=bwperim(biaoji);subplot(2,3,4),subimage(bianyuan);
% biaoji2=bwlabel(bianyuan,8);subplot(2,3,5),subimage(biaoji2);

%%
%形态学去轮廓
[h,w]=size(huitu);
quchu=ones(h,w);quchu(h/2:end,1:end)=0;beijing=im2uint8(quchu)/255;%制造出一个区域把目标之外的区域祛除。
mubiao=immultiply(quchu,bw);%显示祛除背景后纯目标（灰度）图像
SE=strel('disk',2);%strel函数生成结构元素对象，为形态学处理做准备
fushi=imerode(mubiao,SE);
bianyuan2=mubiao-fushi;
subplot(2,2,2),imshow(bianyuan2);
bianyuan3=bwmorph(bianyuan2,'fill');%形态学填充单个像素空洞
bianyuan4=bwfill(bianyuan3,'holes');%填充轮廓内所有区域，包括内部小区域
bianyuan=bwmorph(bianyuan4,'remove');bianyuan1=bwmorph(bianyuan,'bridge');bianyuan=bwmorph(bianyuan,'spur');
% bianyuan=bwmorph(bianyuan1,'thin');
subplot(2,2,3),imshow(bianyuan1);subplot(2,2,4),imshow(bianyuan);
figure,imshow(bianyuan);

