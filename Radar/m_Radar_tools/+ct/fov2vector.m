%--------------------------------------------------------------------------
%   相机的fov角度转换为光路的矢量坐标系
%   输入水平视场角 h_angle 单位为°
%   输入垂直视场角 v_angle 单位为°
%   输入图像尺寸 [u v]
%   笛卡尔坐标系
%   →为X方向 像素的水平方向H
%   ↓为Y方向 像素的垂直方向V
%   ×为Z方向 像素的径向方向Z
%   输入视场角和像素数 得到像素的归一化矢量空间径向方向
%   所有相机按照小孔成像建模,因此矢量的辐射点即为原点(0,0,0)
%   example:
%   计算fov为60°和40° 像素为320x240的投影矢量角度
%   [X,Y,Z] = fov2vector([60 40],[320 240]);
%--------------------------------------------------------------------------
function [X,Y,Z] = fov2vector(angle_shape,shape)
h_angle = angle_shape(1);
v_angle = angle_shape(2);
h = linspace(-h_angle/2,h_angle/2,shape(1));
v = linspace(-v_angle/2,v_angle/2,shape(2));
[H,V] = meshgrid(h,v);
X = 1.*tand(H);                                                             %水平方向矢量
Y = 1.*tand(V);                                                             %垂直方向矢量
Z = 1.*ones(fliplr(shape));
%--------------------------------------------------------------------------
%   矢量归一化
%--------------------------------------------------------------------------
for idx = 1:shape(1)*shape(2)
    R = norm([X(idx) Y(idx) Z(idx)]);
    X(idx) = X(idx)./R;
    Y(idx) = Y(idx)./R;
    Z(idx) = Z(idx)./R;
end
