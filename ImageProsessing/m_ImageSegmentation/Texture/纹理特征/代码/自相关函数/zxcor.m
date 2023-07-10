function [ epsilon,eta,C ] = zxcor(IMG,D,m,n )
%����غ���zxcor������IMGΪͼ��DΪƫ�ƾ��룬m,n��ͼ��ĳߴ�����
%   �˴���ʾ��ϸ˵��

for epsilon=1:D                                 %ѭ�����ͼ��IMG(i,j)��ƫ��ֵΪD������֮������ֵ
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
        C(epsilon, eta)= f2(epsilon, eta)/ f3(epsilon, eta); %���ֵC
   end
end
epsilon =0:(D-1);                                            %x�����ȡֵ��Χ
eta =0:(D-1);                                                %y�����ȡֵ��Χ 

end

