%%
%Also testing the github as well. 
%Read the first image and take the 7 visible points as pixels. 
il=imread('il.jpg');
imshow(il);
[xl,yl]=ginput(7);
left_pixels = [xl, yl];

%Read the second image and take the 7 visible points as pixels. 
ir=imread('ir.jpg');
imshow(ir);
[xr,yr]=ginput(7);
right_pixels = [xr,yr];

%%
format long g;

%These are the pixel densities as observed in Camera Calibration experiment. 
k = 840;
l = 840;

%Convert the pixels to mm using the intrinsic parameters Alpha and Beta for both the images, since, the same camera was used to take these images. 
left_mm = left_pixels/k;
right_mm = right_pixels/l;

%Set the focal length, and the observed base line distance between the two cameras. 
f=4.15;
b=124.46;

%Calculate the disparity for all the points in the same direction in which the camera was moved. 
d=left_mm(:,1) - right_mm(:,1);

%Using the principle of triangulation, calculate the 3D coordinates of the points with respect to camera. 
Z = f*b./d;
X = (left_mm(:,1) .* (Z/f))./Z;
Y = (left_mm(:,2) .* (Z/f))./Z;

%Putting these points together
P = [X Y Z];

%Now, we have the 3D points of the all the 7 points and we can plot it in 3D space. 
plot3(X,Y,Z,'.');
grid on;
hold on;

%Joining the various points individually. 
v1 = P(1,:);
v2 = P(2,:);
v = [v2;v1];
plot3(v(:,1),v(:,2),v(:,3),'r');

v1 = P(2,:);
v2 = P(3,:);
v = [v2;v1];
plot3(v(:,1),v(:,2),v(:,3),'r');

v1 = P(3,:);
v2 = P(4,:);
v = [v2;v1];
plot3(v(:,1),v(:,2),v(:,3),'r');

v1 = P(4,:);
v2 = P(1,:);
v = [v2;v1];
plot3(v(:,1),v(:,2),v(:,3),'r');

v1 = P(5,:);
v2 = P(6,:);
v = [v2;v1];
plot3(v(:,1),v(:,2),v(:,3),'r');

v1 = P(6,:);
v2 = P(7,:);
v = [v2;v1];
plot3(v(:,1),v(:,2),v(:,3),'r');

v1 = P(1,:);
v2 = P(5,:);
v = [v2;v1];
plot3(v(:,1),v(:,2),v(:,3),'r');

v1 = P(2,:);
v2 = P(6,:);
v = [v2;v1];
plot3(v(:,1),v(:,2),v(:,3),'r');

v1 = P(3,:);
v2 = P(7,:);
v = [v2;v1];
plot3(v(:,1),v(:,2),v(:,3),'r');