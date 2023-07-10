clc;clear;close all;
%波束
c=3e8;
fc=24e9;
lamda=c/fc;

% 波束扫描
Scan.Scope=10; %单位°
Scan.Interval=1.5e-3; %单位s
Scan.Beam_Width=0.5; %单位°
Scan.Number=floor(Scan.Scope/Scan.Beam_Width);

% FM波
Wave.B=200e6;
Wave.Tm=1e-3;
Wave.b=Wave.B/Wave.Tm;
Wave.fs=2e6;
Wave.N=4096;
Wave.c=3e8;
Wave.fc=24e9;
Wave.lamda=c/fc;

% 场景
Scene.array=zeros(100,100);
Scene.array(1,:)=1;    Scene.array(100,:)=1;
Scene.array(40:50,100)=1;   Scene.array(37,100)=3;
% Scene.array(1:5:end,100)=3;
figure;imshow(Scene.array);

SeExt=zeros(120,120);
SeExt(10:109,10:109)=Scene.array;
figure;imshow(SeExt);title('Original Scene, Points Array');

Scene.na=size(Scene.array,1);
Scene.nr=size(Scene.array,2);
Scene.Space=0.2;
Scene.R_ref=150;

%载体
Carrier.v=0;
Carrier.x=0;
Carrier.y=0;

%阵列雷达
Radar.Number=10;
Radar.Space=0.18;
Radar.PosArray=(-4.5:1:4.5)*Radar.Space;

% sita-R图
Times=10;
result1=[];
result2=[];

result1=Scan_Single(Scene,Carrier,Scan,Wave,Times,result1);
figure;imshow(3*abs(result1)/max(max(abs(result1))));title('sita-R map, Direct Scan');

result2=Scan_Synthetic(Scene,Carrier,Scan,Wave,Radar,Times,result2);
figure;imshow(3*abs(result2)/max(max(abs(result2))));title('sita-R map, Synthetic Scan');































