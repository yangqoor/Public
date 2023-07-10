 %RGB_YCbCr 
  clc; 
  clear all; 
  close all; 
   
  RGB_data = imread('微信图片_20191227124400.jpg');% 
   
  R_data =    RGB_data(:,:,1); 
  G_data =    RGB_data(:,:,2);
  B_data =    RGB_data(:,:,3);

  imshow(RGB_data);
  title('原图像');

 [ROW,COL, DIM] = size(RGB_data); 
 
 Y_data = zeros(ROW,COL);
 Cb_data = zeros(ROW,COL);
 Cr_data = zeros(ROW,COL);
 Gray_data = RGB_data;
 
 for r = 1:ROW 
    for c = 1:COL
         Y_data(r, c) = 0.299*R_data(r, c) + 0.587*G_data(r, c) + 0.114*B_data(r, c);%彩色图像变为灰度图像公式Gray = R*0.299 + G*0.587 + B*0.114
         Cb_data(r, c) = -0.172*R_data(r, c) - 0.339*G_data(r, c) + 0.511*B_data(r, c) + 128;
        Cr_data(r, c) = 0.511*R_data(r, c) - 0.428*G_data(r, c) - 0.083*B_data(r, c) + 128;
     end
 end 
 
 Gray_data(:,:,1)=Y_data;
 Gray_data(:,:,2)=Y_data;
 Gray_data(:,:,3)=Y_data;
 
 figure;
 imshow(Gray_data);
 title('灰度图像');
 %Median Filter
 imgn = imnoise(Gray_data,'salt & pepper',0.02); %当噪声类型是’salt & pepper’的时候，第三个参数的意思是噪声密度，比如0.1，那么总像素个数的10%为黑白点，当然是黑点还是白点都是随机的。
 
 figure;
 imshow(imgn);
  title('椒盐噪声图像');
 Median_Img = Gray_data;
 for r = 2:ROW-1
     for c = 2:COL-1
         median3x3 =[imgn(r-1,c-1)    imgn(r-1,c) imgn(r-1,c+1)
                     imgn(r,c-1)      imgn(r,c)      imgn(r,c+1)
                     imgn(r+1,c-1)      imgn(r+1,c) imgn(r+1,c+1)];
         sort1 = sort(median3x3, 2, 'descend');%对矩阵的每行进行降序排列
         sort2 = sort([sort1(1), sort1(4), sort1(7)], 'descend');%对矩阵第一列进行降序排列
         sort3 = sort([sort1(2), sort1(5), sort1(8)], 'descend');%对矩阵第二列进行降序排列
         sort4 = sort([sort1(3), sort1(6), sort1(9)], 'descend');%对矩阵第三列进行降序排列
         mid_num = sort([sort2(3), sort3(2), sort4(1)], 'descend');%对第一列最小值，第二列中间值，第三列最大值进行降序排列
         Median_Img(r,c) = mid_num(2);%取中间值
     end
 end
 
 figure;
 imshow(Median_Img);
  title('中值滤波后图像');
 %Sobel_Edge_Detect
 
 Median_Img = double(Median_Img);
 Sobel_Threshold = 150;
 Sobel_Img = zeros(ROW,COL);
 for r = 2:ROW-1
     for c = 2:COL-1
         Sobel_x = Median_Img(r-1,c+1) + 2*Median_Img(r,c+1) + Median_Img(r+1,c+1) - Median_Img(r-1,c-1) - 2*Median_Img(r,c-1) - Median_Img(r+1,c-1);
         Sobel_y = Median_Img(r-1,c-1) + 2*Median_Img(r-1,c) + Median_Img(r-1,c+1) - Median_Img(r+1,c-1) - 2*Median_Img(r+1,c) - Median_Img(r+1,c+1);
         Sobel_Num = abs(Sobel_x) + abs(Sobel_y);
         %Sobel_Num = sqrt(Sobel_x^2 + Sobel_y^2);
         if(Sobel_Num > Sobel_Threshold)            
             Sobel_Img(r,c)=0;
         else
             Sobel_Img(r,c)=255;
         end
     end
 end
 
 figure;
 imshow(Sobel_Img);
  title('Sobel边缘检测图像');


% clear;clc;  
% I=imread('微信图片_20191227124400.jpg'); 
% I=rgb2gray(I);
% imshow(I); 
% title('灰度图像'); 
% 
% sobelBW=edge(I,'sobel'); 
% figure;
% imshow(sobelBW);
% title('Sobel Edge'); 
% 
% robertsBW=edge(I,'roberts');
% figure; 
% imshow(robertsBW); 
% title('Roberts Edge'); 
% 
% prewittBW=edge(I,'prewitt'); 
% figure;
% imshow(prewittBW); 
% title('Prewitt Edge');
% 
% logBW=edge(I,'log');
% figure;
% imshow(logBW);
% title('Laplasian of Gaussian Edge');  
% 
% cannyBW=edge(I,'canny');
% figure; 
% imshow(cannyBW); 
% title('Canny Edge');