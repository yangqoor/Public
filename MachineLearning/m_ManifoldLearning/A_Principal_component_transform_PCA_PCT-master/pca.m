clear
close all
image = imread('mandril_color.tif');
[row,col,band_num] = size(image);
I=rgb2gray(image);
figure
imshow(I);
%%
% convert image pixels to floating numbers将图像像素转换为浮点数
image = double(image);

% mean and normalizing image均值归一化图像
for i=1:band_num
    % finding bandwise mean 寻找维度平均值
    mean(1,i) = mean2(image(:,:,i));
    % bandwise normalization bandwise归一化
    X(:,:,i)=image(:,:,i)-mean(1,i)*ones(row,col);
    Y(:,:,i)=image(:,:,i)-mean(1,i)*ones(row,col);
end

% for covariance matrix 协方差矩阵
sum1=0;
for m=1:band_num
    for k=1:band_num
         for ro=1:row
            for co=1:col
                z=X(ro,co,m)*Y(ro,co,k);
                sum1= sum1+z;
            end
         end
         cov = sum1/((row*col)-1);
         cov_mat(m,k)=cov;
         sum1=0;
    end
end
    
                

% eigen value(val) and eigen vector(vect)特征值（val）和特征向量（vect）
[vect,val] = eig(cov_mat);
% columnise eigen value纵列特征值
val = diag(val);
% sorting eigen value in descending order with their indices按指数降序排列特征值
[sort_val,index]=sort(val,'descend');

% sorting eigen vectors according to corresponding sorted eigen values根据相应的排序特征值对特征向量进行排序
for j=1:length(sort_val)
    sort_vect(:,j) = vect(:,index(j));
end

% 
for r=1:row
    for c=1:col
        for b=1:band_num
            % pixel value of normalized image归一化图像的像素值
            norml_img(b,1)= X(r,c,b);
        end
        % transformed value of each pixel每个像素的变换值
        % transformed = feture vector transpose * normalized image转换=获取矢量转置*归一化图像
        pct = sort_vect.'*norml_img;
        for count=1:band_num
            % principal component主成分
            pct_img(r,c,count)=pct(count,1);
        end
    end
end


figure, imshow(pct_img(:,:,1),[]);
figure, imshow(pct_img(:,:,2),[]);
figure, imshow(pct_img(:,:,3),[]);
figure, imshow(pct_img(),[]);