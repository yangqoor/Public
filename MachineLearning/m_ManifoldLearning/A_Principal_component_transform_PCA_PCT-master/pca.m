clear
close all
image = imread('mandril_color.tif');
[row,col,band_num] = size(image);
I=rgb2gray(image);
figure
imshow(I);
%%
% convert image pixels to floating numbers��ͼ������ת��Ϊ������
image = double(image);

% mean and normalizing image��ֵ��һ��ͼ��
for i=1:band_num
    % finding bandwise mean Ѱ��ά��ƽ��ֵ
    mean(1,i) = mean2(image(:,:,i));
    % bandwise normalization bandwise��һ��
    X(:,:,i)=image(:,:,i)-mean(1,i)*ones(row,col);
    Y(:,:,i)=image(:,:,i)-mean(1,i)*ones(row,col);
end

% for covariance matrix Э�������
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
    
                

% eigen value(val) and eigen vector(vect)����ֵ��val��������������vect��
[vect,val] = eig(cov_mat);
% columnise eigen value��������ֵ
val = diag(val);
% sorting eigen value in descending order with their indices��ָ��������������ֵ
[sort_val,index]=sort(val,'descend');

% sorting eigen vectors according to corresponding sorted eigen values������Ӧ����������ֵ������������������
for j=1:length(sort_val)
    sort_vect(:,j) = vect(:,index(j));
end

% 
for r=1:row
    for c=1:col
        for b=1:band_num
            % pixel value of normalized image��һ��ͼ�������ֵ
            norml_img(b,1)= X(r,c,b);
        end
        % transformed value of each pixelÿ�����صı任ֵ
        % transformed = feture vector transpose * normalized imageת��=��ȡʸ��ת��*��һ��ͼ��
        pct = sort_vect.'*norml_img;
        for count=1:band_num
            % principal component���ɷ�
            pct_img(r,c,count)=pct(count,1);
        end
    end
end


figure, imshow(pct_img(:,:,1),[]);
figure, imshow(pct_img(:,:,2),[]);
figure, imshow(pct_img(:,:,3),[]);
figure, imshow(pct_img(),[]);