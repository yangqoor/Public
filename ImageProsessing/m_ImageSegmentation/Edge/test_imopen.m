% 形态学实例——从PCB图像中删除所有电流线，仅保留芯片对象
I = imread('circbw.tif');
imshow(I);
SE = strel('rectangle', [40 30]); % 结构定义
J = imopen(I, SE);                % 开运算
figure, imshow(J);
