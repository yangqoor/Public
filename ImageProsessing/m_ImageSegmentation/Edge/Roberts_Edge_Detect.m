clc;
clear all;
img = imread('΢��ͼƬ_20191227124400.jpg'); % ��ȡͼ��
figure;
imshow(img);
title('ԭʼͼ��');
img_gray = rgb2gray(img); % ת���ɻҶ�ͼ
figure;
imshow(img_gray);
title('�Ҷ�ͼ��');
[m,n] = size(img_gray); % �õ�ͼ��Ĵ�С
new_img_gray = img_gray; % �½�һ��һ�����ͼ�� 
pxValue = 0; % roberts�������õ�������ֵ 
% �Ա߽����ز��� 
threshold_value=30;     
    for i=1:m-1        
        for j=1:n-1          
            pxValue = abs(img_gray(i,j)-img_gray(i+1,j+1))+...  
                abs(img_gray(i+1,j)-img_gray(i,j+1));      
            if(pxValue > threshold_value)      
                new_img_gray(i,j) = 0;          
            else
                new_img_gray(i,j) =255;      
            end
        end
    end
    figure;
    imshow(new_img_gray);  
    title('roberts��Ե���ͼ��');