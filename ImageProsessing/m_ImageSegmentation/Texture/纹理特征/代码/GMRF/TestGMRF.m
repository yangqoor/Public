%test GMRF Texture
close all;
clear;
clc;
% Img=imread('texture.jpg');%gray-level image
Img=imread('1.jpg');
figure,imshow(Img,[]);
%EstiPara_Gmrf2=X_GmrfPara_2Order_Estimat(Img,8);
%EstiPara_Gmrf4=X_GmrfPara_4Order_Estimat(Img,8);
EstiPara_Gmrf5=X_GmrfPara_5Order_Estimat(Img,8);