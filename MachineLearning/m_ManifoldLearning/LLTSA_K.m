clc
clear
close all
% load('swiss_holedata.mat')
%%
% tt     = (3*pi/2)*(1+2*rand(1,2000)); 
% height = 21*rand(1,2000);
% X  = [height;tt.*sin(tt);tt.*cos(tt)]';
v=importdata('F:\\spot_video\\50mw_part\\light.txt');
w=importdata('F:\\spot_video\\50mw_part\\area.txt');
x=importdata('F:\\spot_video\\50mw_part\\perimeter.txt');
y=importdata('F:\\spot_video\\50mw_part\\long_axis.txt');
z=importdata('F:\\spot_video\\50mw_part\\short_axis.txt');
r=importdata('F:\\spot_video\\50mw_part\\ratio.txt');
X=[v w x y z r];
% load('swiss_roll.mat')

%% 参数设置
% X=maniX;

%%
no_dims=3;
for k=10:13;
figure('NumberTitle', 'off', 'Name',strcat('邻近点个数为：',num2str(k)));
title(['邻近点个数为：',num2str(k)]);
% [mappedX, mapping] = lltsa(X, no_dims, k);%线性局部切空间排列算法
% [mappedX, mapping] = lpp(X, no_dims, k);%局部保持投影算法（效果好）
% [mappedX, mapping] = lle(X, no_dims, k);
% [mappedX, mapping] = isomap(X, no_dims, k);
% mappedX = hlle(X, no_dims, k);%有全零行报错（ROI提取背景保留过多）
mappedX = ltsa(X, no_dims, k);%局部坐标表示算法%有全零行报错（效果好）
n=length(mappedX);
c=1:n;
scatter3(mappedX(:,1),mappedX(:,2),mappedX(:,3),10,c');
end
%%
% no_dims=2;
% figure;
% for k=10:18;
% 
% % [mappedX, mapping] = lltsa(X, no_dims, k);%线性局部切空间排列算法(效果好)
% [mappedX, mapping] = lpp(X, no_dims, k);%局部保持投影算法(效果好)
% % [mappedX, mapping] = lle(X, no_dims, k);
% % mappedX = hlle(X, no_dims, k);%有全零行报错（ROI提取背景保留过多）
% % [mappedX, mapping] = isomap(X, no_dims, k);
% % mappedX = ltsa(X, no_dims, k);%局部坐标表示算法%有全零行报错
% 
% subplot(3,3,(k-9))
% xlabel(['邻近点个数为：',num2str(k)])
% grid on
% hold on
% n=length(mappedX);
% c=1:n;
% % scatter(mappedX(:,1),mappedX(:,2),20,tt')
% scatter(mappedX(:,1),mappedX(:,2),10,c')
% end