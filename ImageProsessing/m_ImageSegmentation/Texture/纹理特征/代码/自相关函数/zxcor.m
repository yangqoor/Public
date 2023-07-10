function [ epsilon,eta,C ] = zxcor(IMG,D,m,n )
%自相关函数zxcor（），IMG为图像，D为偏移距离，m,n是图像的尺寸数据
%   此处显示详细说明

for epsilon=1:D                                 %循环求解图像IMG(i,j)与偏离值为D的像素之间的相关值
  for eta=1:D                
     temp=0;
     fp=0;
     for x=1:m
        for y=1:n
           if(x+ epsilon -1)>m||(y+ eta -1)>n
             f1=0;
           else   
            f1=IMG(x,y)*IMG(x+ epsilon -1,y+ eta -1);     
           end
           temp=f1+temp;
           fp=IMG(x,y)*IMG(x,y)+fp;
        end      
     end 
        f2(epsilon, eta)=temp;
        f3(epsilon, eta)=fp;
        C(epsilon, eta)= f2(epsilon, eta)/ f3(epsilon, eta); %相关值C
   end
end
epsilon =0:(D-1);                                            %x方向的取值范围
eta =0:(D-1);                                                %y方向的取值范围 

end

