%% 本程序处理手枪的图像
load gun3.mat ;

Th=305; Tl=250;
Dh=max2(gun1);Dl=min2(gun1);
k=(Th-Tl)/(Dh-Dl);b=Tl;
T=(gun1-Dl)*k+b;

%normalize temprature;
% Tn=T/320;      %最高温度选择为320
% limit=160/320; %归一化温度的下限
% imshow(Tn,[]);

T1=interp2(T,4,'cubic');
% m=10;
% T2=T1(1:241,1+m:241+m);
% imshow(T2,[]);

psf=fspecial('gaussian',[31,31],11);
%psf=ones(9,9)/81;
T1=conv2(T1,psf,'valid');
T2=1-T1/max2(T1);
T2=T2(1:1:end,1:1:end);
figure;imshow(T2,[]);

