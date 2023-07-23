%% draw concentric circles
% 为RNR准备试验用图
clear;
im=zeros(256,256);

%draw the center point
radius=10;
im1=draw_circle(im,radius);

%draw the first inner circle
radius=30;
im1=draw_circle(im1,radius);

%draw the 2nd circle
radius=50;
im1=draw_circle(im1,radius);

%draw the 3rd inner circle
radius=62;
im1=draw_circle(im1,radius);
%%  
[mi,ni]=size(im1);

%margin of image to left right up down
margin=4; 

%first fmi,fni of subimage 
dmi=mi/4;dni=ni/4; %step of delta mi,ni
fmi=round((1+dmi)/2);fni=round((1+dni)/2);

for k=1:4
    for s=1:4
        if k==1 | s==1 |k==4 | s==4
           center(1)=fmi+(k-1)*dmi;
           center(2)=fni+(s-1)*dni;
        
           %画出3个子圆
           radius1=dmi/2-margin;
           im1=draw_circle(im1,radius1,center);
        
           radius2=radius1-13;
           im1=draw_circle(im1,radius2,center);
        
%            radius3=radius2-8;
%            im1=draw_circle(im1,radius3,center);
        end
         % figure;imshow(im1);
    end
end

im1=double(im1); 
figure;imshow(im1);
artimage=im1;
save artimage artimage;