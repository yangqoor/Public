

clc
clear all
close all
% load('swiss_holedata.mat')
%%
% tt     = (3*pi/2)*(1+2*rand(1,2000)); 
% height = 21*rand(1,2000);
% X  = [height;tt.*sin(tt);tt.*cos(tt)]';
x=importdata('F:\\spot_video\\data\\50&20&10\\light.txt');
y=importdata('F:\\spot_video\\data\\50&20&10\\area.txt');
z=importdata('F:\\spot_video\\data\\50&20&10\\long_axis.txt');
X=[x y z];
% load('swiss_roll.mat')

%% ��������
% X=maniX;
no_dims=2;
figure;
for k=10:18;
%%
%[mappedX, mapping] = lltsa(X, no_dims, k);%���Ծֲ��пռ������㷨
%      [mappedX, mapping] = lpp(X, no_dims, k);%�ֲ�����ͶӰ�㷨
    mappedX = ltsa(X, no_dims, k);%�ֲ������ʾ�㷨
  
%%
subplot(3,3,(k-9))
xlabel(['�ڽ������Ϊ��',num2str(k)])
grid on
hold on
% scatter(mappedX(:,1),mappedX(:,2),20,tt')
scatter(mappedX(:,1),mappedX(:,2),20')
end
figure
scatter3(x,y,z);
% scatter3(X(:,1),X(:,2),X(:,3),12,tt');