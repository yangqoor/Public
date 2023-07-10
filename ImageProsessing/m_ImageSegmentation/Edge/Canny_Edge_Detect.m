clc;
clear all;
image = imread('΢��ͼƬ_20191227124400.jpg'); 
image = rgb2gray(image);
subplot(221); 
imshow(image); 
title('ԭʼͼ��'); 

image = double(image)/256; 
[m,n] = size(image); 
w = fspecial('gaussian');
image_1 = imfilter(image,w,'replicate');%�˲�
subplot(222);
imshow(int8(256*image_1)); 
title('��˹�˲����ͼ��');  % �ݶȼ���

op = fspecial('sobel')/4;  % ��Sobel���������� 
x = op'; y =op; 
bx = imfilter(image_1,x,'replicate');
by = imfilter(image_1,y,'replicate'); 
b_abs = sqrt(bx.*bx+by.*by);        % ���ݶȵķ�ֵ 
b_angle = angle(by-i*bx);
b_ang = b_angle/3.1416*180;         % ���ݶȵķ��� 

% �ݶȷ���ȷ��
for r = 1:m   
    for c = 1:n        
        if((b_ang(r,c)>=22.5 && b_ang(r,c)<67.5) || (b_ang(r,c)>=-157.5 && b_ang(r,c)<-112.5))           
                dir(r,c) = 1;        
        else if ((b_ang(r,c)>=67.5 && b_ang(r,c)<112.5)|| (b_ang(r,c)>=-112.5 && b_ang(r,c)<-67.5))        
                dir(r,c) = 2;        
            else if ((b_ang(r,c)>=112.5 && b_ang(r,c)<157.5)|| (b_ang(r,c)>=-67.5 && b_ang(r,c)<-22.5))           
                    dir(r,c) = 3;        
                else
                    dir(r,c) = 0;  
                end
                end
        end
    end
end

% ����ͼ��
        b_ab = [zeros(m,1),b_abs,zeros(m,1)];    % ��������
        b_ab = [zeros(1,n+2);b_ab;zeros(1,n+2)]; %�൱�������ݶȺ������ֵ����һ��0
        for r = 2:m+1     
            for c = 2:n+1        
                switch dir(r-1,c-1)             
                    case 0                 
                        if((b_ab(r,c)<b_ab(r+1,c))| (b_ab(r,c)<b_ab(r-1,c)))                   
                            b1(r-1,c-1) = 0;                
                        else
                            b1(r-1,c-1) = b_ab(r,c);                
                        end
                    case 1               
                        if((b_ab(r,c)<b_ab(r+1,c-1))| (b_ab(r,c)<b_ab(r-1,c+1)))                
                            b1(r-1,c-1) = 0;                
                        else
                            b1(r-1,c-1) = b_ab(r,c);             
                        end
                    case 2               
                        if((b_ab(r,c)<b_ab(r,c-1))| (b_ab(r,c)<b_ab(r,c+1)))                 
                            b1(r-1,c-1) = 0;              
                        else
                            b1(r-1,c-1) = b_ab(r,c);             
                        end
                    case 3             
                        if((b_ab(r,c)<b_ab(r-1,c-1))| (b_ab(r,c)<b_ab(r+1,c+1)))              
                            b1(r-1,c-1) = 0;               
                        else
                            b1(r-1,c-1) = b_ab(r,c);                
                        end
                end
            end
        end
        
        for r = 1:m     
            for c = 1:n        
                if (b1(r,c)>0.24)           
                    b2(r,c) = 1;       
                else
                    b2(r,c) = 0;       
                end
            end
        end
        
        for r = 1:m    
            for c = 1:n       
                if(b1(r,c)>0.36)           
                    b3(r,c)=1;       
                else
                    b3(r,c) = 0;       
                end
            end
        end
        
        image_2 = b3; 
        for k = 1:10    
            for r = 2:m-1     
                for c = 2: n-1          
                    if (b2(r,c)==1 && (image_2(r,c)==1||image_2(r+1,c)==1 ...
                        ||image_2(r+1,c-1)==1||image_2(r+1,c+1)==1||image_2(r,c-1)==1 ...
                    ||image_2(r,c+1)==1||image_2(r-1,c-1)==1||image_2(r-1,c)==1 ...
                    ||image_2(r-1,c+1)==1))                 
                        image_2(r,c) = 1;        
                    else
                        image_2(r,c) = 0;          
                    end
                end
            end
        end
        subplot(223);
        imshow(image_2);
        title('Canny���Ӽ����ͼ��');