%--------------------------------------------------------------------------
%   [undistorted_img,...
%    pixel_trans_u,...
%    pixel_trans_v] = undistortImage2(img, K, D)
%--------------------------------------------------------------------------
%   ���ܣ�
%   ͼ����������ԭ(�����ѻ��仹ԭ�㷨)
%--------------------------------------------------------------------------
%   ���룺
%           img                     ��У��ͼ��
%           K                       �ڲξ���
%           D                       �������ϵ��k1 k2
%   �����
%           undistorted_img         У����ͼ��
%           pixel_trans_u           ˮƽ����
%           pixel_trans_v           ��ֱ����
%--------------------------------------------------------------------------
%   ���ӣ�
%   images = imageDatastore(fullfile(toolboxdir('vision'),'visiondata', ...
%     'calibration','mono'));
%   [imagePoints,boardSize] = detectCheckerboardPoints(images.Files);
%   squareSize = 29;
%   worldPoints = generateCheckerboardPoints(boardSize,squareSize);
%   I = readimage(images,1); 
%   imageSize = [size(I,1),size(I,2)];
%   cameraParams = estimateCameraParameters(imagePoints,worldPoints, ...
%                                   'ImageSize',imageSize);
%
%   [uimxy,u,v] = undistortImage2(I,...
%                                 cameraParams.IntrinsicMatrix.',...
%                                 cameraParams.RadialDistortion);
%--------------------------------------------------------------------------
function [undistorted_img,...
        pixel_trans_u,...
        pixel_trans_v] = undistortImage2(img, K, D)
[height, width,~] = size(img);                                               %��ȡͼƬ�ߴ�
fx = K(1,1);                                                                %�ڲξ��� x�����������
fy = K(2,2);                                                                %�ڲξ��� y�����������
cx = K(1,3);                                                                %x��������ƫ�Ʋ���
cy = K(2,3);                                                                %y��������ƫ�Ʋ���

undistorted_img = eval([class(img) '(zeros(size(img)))']);                             %�����󻺳�����
pixel_trans_u = zeros(height,width);
pixel_trans_v = zeros(height,width);
%--------------------------------------------------------------------------
%   ͼ��ԭʼ����������
%--------------------------------------------------------------------------
[X,Y] = meshgrid(1:width,1:height);                                         %X Y ��ʾˮƽ ��ֱ��������

%--------------------------------------------------------------------------
%   �ڲξ����һ�������������
%--------------------------------------------------------------------------
X1 = (X-cx)./fx;
Y1 = (Y-cy)./fy;

%--------------------------------------------------------------------------
%   �������ģ�͵õ���һ���Ļ�������
%--------------------------------------------------------------------------
R2 = X1.^2+Y1.^2;
X2 = X1.*(1+D(1).*R2+D(2).*R2.^2);
Y2 = Y1.*(1+D(1).*R2+D(2).*R2.^2);

%--------------------------------------------------------------------------
%   ����ӳ�����굽ԭʼͼ��
%--------------------------------------------------------------------------
u_distorted = fx.*X2 + cx;                                                  %ͼ���������
v_distorted = fy.*Y2 + cy;                                                  %ͼ���������

%--------------------------------------------------------------------------
%   ����Խ�紦��
%--------------------------------------------------------------------------
%   ˮƽ����
%--------------------------------------------------------------------------
u_distorted(u_distorted<1)=nan;
u_distorted(u_distorted>width)=nan;

%--------------------------------------------------------------------------
%   ��ֱ����
%--------------------------------------------------------------------------
v_distorted(v_distorted<1)=nan;
v_distorted(v_distorted>height)=nan;

%--------------------------------------------------------------------------
%   �����������
%--------------------------------------------------------------------------
for xdx = 1:width
    for ydx = 1:height
        if isnan(u_distorted(ydx,xdx)) || isnan(v_distorted(ydx,xdx))
            continue
        else
            %   Ӧ�ò������ڽ���ֵ,����͵��ֱ��ѡ��������������
            undistorted_img(ydx,xdx,:) = img(round(v_distorted(ydx,xdx)),round(u_distorted(ydx,xdx)),:);
            pixel_trans_u(ydx,xdx) = u_distorted(ydx,xdx);
            pixel_trans_v(ydx,xdx) = v_distorted(ydx,xdx);
        end
    end
end
