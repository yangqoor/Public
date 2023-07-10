I=imread('Î¢ÐÅÍ¼Æ¬_20191227124400.jpg');
I=im2double(I);
figure;
imshow(I);
title('Ô­Ê¼Í¼Ïñ'); 
img_gray = rgb2gray(I); % ×ª»»³É»Ò¶ÈÍ¼
figure;
imshow(img_gray);
title('»Ò¶ÈÍ¼Ïñ');
[height width R]=size(img_gray); 
threshold_value=0.5;     
for i=2:height-1    
    for j=2:width-1      
        Dx=[I(i+1,j-1)-I(i-1,j-1)]+[I(i+1,j)-I(i-1,j)]+[I(i+1,j+1)-I(i-1,j+1)];      
        Dy=[I(i-1,j+1)-I(i-1,j-1)]+[I(i,j+1)-I(i,j-1)]+[I(i+1,j+1)-I(i+1,j-1)];       
        P(i,j)=sqrt(Dx^2+Dy^2);    
          if (P(i,j)>threshold_value)        
            P(i,j)=0;       
          else
              P(i,j)=255;
    end
    end
end
figure;
imshow(P);
title('prewitt±ßÔµ¼ì²âÍ¼Ïñ');
