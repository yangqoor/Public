%%
%fig0�У�����0ʱ��ͼ�����������
clc;clear;
yuantu=imread('001.bmp');
huitu=rgb2gray(yuantu);
subplot(2,2,1),imtool(huitu);%����������»Ҷȷ�Χ
%%
bw=roicolor(huitu,0,100);%�ڻҶ�0~100����Ϊroi��������ȫΪ����    %���ܹؼ����Բ�ͬͼ��Ҫ�޸����
%%
% subplot(2,3,1),subimage(huitu);colorbar('veit');
% subplot(2,3,2),subimage(bw);
% bw=im2uint8(bw)/255;%���������255��������0~255���߼�0��Ϊ0,1��Ϊ255
% % hetu=immultiply(huitu,bw);%��ҪĿ��ĻҶ�ͼ��Ļ�����ѡ���
% %%
% %��̬ѧ������Ҫ��Ϊ�������Ե�ر�ë������
% SE=strel('disk',2);%strel�������ɽṹԪ�ض���Ϊ��̬ѧ������׼��
% biyunsuan=imclose(bw,SE);
% [h,w]=size(huitu);
% quchu=ones(h,w);quchu(h/2:end,1:end)=0;beijing=im2uint8(quchu)/255;%�����һ�������Ŀ��֮������������
% mubiao=immultiply(beijing,biyunsuan);%��ʾ���������Ŀ�꣨�Ҷȣ�ͼ��
% subplot(2,3,3);subimage(mubiao);
% [level EM] = graythresh(mubiao);%EMΪ��Ӧ�ľ���level��graythresh�������ֵ
% erzhi=im2bw(mubiao,level);%��ֵ��Χ0~1��Ĭ��0.5�������ú�����ȡ��ֵlevel.
% biaoji=bwlabel(erzhi,8);
% bianyuan=bwperim(biaoji);subplot(2,3,4),subimage(bianyuan);
% biaoji2=bwlabel(bianyuan,8);subplot(2,3,5),subimage(biaoji2);

%%
%��̬ѧȥ����
[h,w]=size(huitu);
quchu=ones(h,w);quchu(h/2:end,1:end)=0;beijing=im2uint8(quchu)/255;%�����һ�������Ŀ��֮������������
mubiao=immultiply(quchu,bw);%��ʾ���������Ŀ�꣨�Ҷȣ�ͼ��
SE=strel('disk',2);%strel�������ɽṹԪ�ض���Ϊ��̬ѧ������׼��
fushi=imerode(mubiao,SE);
bianyuan2=mubiao-fushi;
subplot(2,2,2),imshow(bianyuan2);
bianyuan3=bwmorph(bianyuan2,'fill');%��̬ѧ��䵥�����ؿն�
bianyuan4=bwfill(bianyuan3,'holes');%����������������򣬰����ڲ�С����
bianyuan=bwmorph(bianyuan4,'remove');bianyuan1=bwmorph(bianyuan,'bridge');bianyuan=bwmorph(bianyuan,'spur');
% bianyuan=bwmorph(bianyuan1,'thin');
subplot(2,2,3),imshow(bianyuan1);subplot(2,2,4),imshow(bianyuan);
figure,imshow(bianyuan);

