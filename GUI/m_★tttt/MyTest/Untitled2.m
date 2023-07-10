figure;imshow(Arr(1:120,:),[]);%原图
figure;imshow(bw4);%二值化

bw7=imdilate(bw4,strel('rectangle',[5,5]));
bw7=imerode(bw7,strel('rectangle',[5,5]));
bw7=imerode(bw7,strel('rectangle',[1,130]));

bw7=imdilate(bw7,strel('rectangle',[1,1]));
figure;imshow(bw7);%
% bw7 = bwareaopen(bw7,120,8);%去除小面积
% bw7=imdilate(bw7,strel('rectangle',[5,5]));
% bw7=imerode(bw7,strel('rectangle',[5,5]));
% figure;imshow(bw7);% 干扰


