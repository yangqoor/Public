P = phantom(256);%生成头骨幻影图像
imshow(P)%显示头骨幻影图像
theta1 = 0:10:170;%投影的角度，步长为10
[R1,xp] = radon(P,theta1);%radon变换
num_angles_R1 = size(R1,2);%角度的个数
theta2 = 0:5:175;%投影角度，步长为5
[R2,xp] = radon(P,theta2);%radon变换
num_angles_R2 = size(R2,2);%角度的个数
theta3 = 0:2:178;%投影角度，步长为2
[R3,xp] = radon(P,theta3);%radon变换
num_angles_R3 = size(R3,2);%角度的个数
N_R1 = size(R1,1);%角度步长为10时对角线的长度
N_R2 = size(R2,1);%角度步长为5时对角线的长度
N_R3 = size(R3,1);%角度步长为2时对角线的长度
figure, 
imagesc(theta3,xp,R3);%显示角度步长为2时的Radon变换
colormap(hot); colorbar
xlabel('旋转角度'); ylabel('感知器位置');
output_size = max(size(P));%确定变换后图像的大小
dtheta1 = theta1(2) - theta1(1);%步长
I1 = iradon(R1,dtheta1,output_size);%radon逆变换
figure, 
subplot(1,3,1), imshow(I1)%显示逆变换的图像
dtheta2 = theta2(2) - theta2(1);%步长
I2 = iradon(R2,dtheta2,output_size);%radon逆变换
subplot(1,3,2),  imshow(I2)%显示逆变换的图像
dtheta3 = theta3(2) - theta3(1);%步长
I3 = iradon(R3,dtheta3,output_size);%radon逆变换
subplot(1,3,3),  imshow(I3)%显示逆变换的图像
D = 250; dsensor1 = 2;
F1 = fanbeam(P,D,'FanSensorSpacing',dsensor1);%fanbeam变换
dsensor2 = 1;
F2 = fanbeam(P,D,'FanSensorSpacing',dsensor2);%fanbeam变换
dsensor3 = 0.25;
[F3, sensor_pos3, fan_rot_angles3] = fanbeam(P,D,...
                           'FanSensorSpacing',dsensor3);%fanbeam变换
figure, 
imagesc(fan_rot_angles3, sensor_pos3, F3)%显示fanbeam变换的图像
colormap(hot);  colorbar
xlabel('旋转角度');  ylabel('感知器位置')
Ifan1 = ifanbeam(F1,D,'FanSensorSpacing',...
    			dsensor1,'OutputSize',output_size);%fambeam逆变换
figure, 
subplot(1,3,1), imshow(Ifan1)%显示重构图像
Ifan2 = ifanbeam(F2,D,'FanSensorSpacing',...
   	 		dsensor2,'OutputSize',output_size);%fanbeam逆变换
subplot(1,3,2), imshow(Ifan2)%显示重构图像
Ifan3 = ifanbeam(F3,D,'FanSensorSpacing',...
    		dsensor3,'OutputSize',output_size);%fanbeam逆变换
subplot(1,3,3), imshow(Ifan3)%显示重构图像
