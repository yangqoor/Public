P = phantom(256);%����ͷ�ǻ�Ӱͼ��
imshow(P)%��ʾͷ�ǻ�Ӱͼ��
theta1 = 0:10:170;%ͶӰ�ĽǶȣ�����Ϊ10
[R1,xp] = radon(P,theta1);%radon�任
num_angles_R1 = size(R1,2);%�Ƕȵĸ���
theta2 = 0:5:175;%ͶӰ�Ƕȣ�����Ϊ5
[R2,xp] = radon(P,theta2);%radon�任
num_angles_R2 = size(R2,2);%�Ƕȵĸ���
theta3 = 0:2:178;%ͶӰ�Ƕȣ�����Ϊ2
[R3,xp] = radon(P,theta3);%radon�任
num_angles_R3 = size(R3,2);%�Ƕȵĸ���
N_R1 = size(R1,1);%�ǶȲ���Ϊ10ʱ�Խ��ߵĳ���
N_R2 = size(R2,1);%�ǶȲ���Ϊ5ʱ�Խ��ߵĳ���
N_R3 = size(R3,1);%�ǶȲ���Ϊ2ʱ�Խ��ߵĳ���
figure, 
imagesc(theta3,xp,R3);%��ʾ�ǶȲ���Ϊ2ʱ��Radon�任
colormap(hot); colorbar
xlabel('��ת�Ƕ�'); ylabel('��֪��λ��');
output_size = max(size(P));%ȷ���任��ͼ��Ĵ�С
dtheta1 = theta1(2) - theta1(1);%����
I1 = iradon(R1,dtheta1,output_size);%radon��任
figure, 
subplot(1,3,1), imshow(I1)%��ʾ��任��ͼ��
dtheta2 = theta2(2) - theta2(1);%����
I2 = iradon(R2,dtheta2,output_size);%radon��任
subplot(1,3,2),  imshow(I2)%��ʾ��任��ͼ��
dtheta3 = theta3(2) - theta3(1);%����
I3 = iradon(R3,dtheta3,output_size);%radon��任
subplot(1,3,3),  imshow(I3)%��ʾ��任��ͼ��
D = 250; dsensor1 = 2;
F1 = fanbeam(P,D,'FanSensorSpacing',dsensor1);%fanbeam�任
dsensor2 = 1;
F2 = fanbeam(P,D,'FanSensorSpacing',dsensor2);%fanbeam�任
dsensor3 = 0.25;
[F3, sensor_pos3, fan_rot_angles3] = fanbeam(P,D,...
                           'FanSensorSpacing',dsensor3);%fanbeam�任
figure, 
imagesc(fan_rot_angles3, sensor_pos3, F3)%��ʾfanbeam�任��ͼ��
colormap(hot);  colorbar
xlabel('��ת�Ƕ�');  ylabel('��֪��λ��')
Ifan1 = ifanbeam(F1,D,'FanSensorSpacing',...
    			dsensor1,'OutputSize',output_size);%fambeam��任
figure, 
subplot(1,3,1), imshow(Ifan1)%��ʾ�ع�ͼ��
Ifan2 = ifanbeam(F2,D,'FanSensorSpacing',...
   	 		dsensor2,'OutputSize',output_size);%fanbeam��任
subplot(1,3,2), imshow(Ifan2)%��ʾ�ع�ͼ��
Ifan3 = ifanbeam(F3,D,'FanSensorSpacing',...
    		dsensor3,'OutputSize',output_size);%fanbeam��任
subplot(1,3,3), imshow(Ifan3)%��ʾ�ع�ͼ��
