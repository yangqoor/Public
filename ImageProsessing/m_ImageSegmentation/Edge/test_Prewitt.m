% Prewitt算子检测图像的边缘
I = imread('bacteria.BMP');
BW1 = edge(I, 'prewitt', 0.04);         %  0.04为梯度阈值
figure(1);
imshow(I);
figure(2);
imshow(BW1);
