%%
%******************************椭圆数据***********************************
clear all
format long;
clc;
ellipse=[1,0.675,0.286,-0.153,0.4,0]; % 1衰减系数 2长轴 3短轴 4中心x坐标 5中心y坐标 6转角
n=100;
Img=creat_ellipse(ellipse,n);
figure
subplot(2,2,1);
imshow(Img,[]);
title('原始图像');
%%
%投影
pi=3.14159;
D=2;
alpha=ellipse(6)*pi/180;
per_gamma=pi*1/180;
per_beta=pi*1/180;
sum_beta=360;
sum_gamma=120;
pro=zeros(sum_beta,sum_gamma);
for beta=1:sum_beta
    for gamma=-sum_gamma/2+1:sum_gamma/2
        phi=pi*(beta+gamma)/180;
        d=D*sin(pi*gamma/180);
        alpha=pi*ellipse(6)/180;
        phi=phi;
        r_alpha=ellipse(2)^2*(cos(phi-alpha))^2+ellipse(3)^2*(sin(phi-alpha))^2;
        D_alpha=d-ellipse(4)*cos(phi)-ellipse(5)*sin(phi);
        if abs(D_alpha^2) <= r_alpha
           y=2*ellipse(1)*ellipse(2)*ellipse(3)*sqrt(r_alpha-D_alpha^2)/r_alpha;
        else
           y=0;
        end    
        pro(beta,gamma+sum_gamma/2)=pro(beta,gamma+sum_gamma/2)+y;
    end
end
subplot(2,2,2);
imshow(pro,[]);
title('投影');
%%
%滤波函数
h=-sum_gamma:sum_gamma;
h1=-sum_gamma:sum_gamma;
for k=-sum_gamma:sum_gamma
    if k==0 
        h1(k+sum_gamma+1)=1/4/per_gamma/per_gamma;
    elseif mod(k,2)==1
        h1(k+sum_gamma+1)=-1/(k*pi*per_gamma)^2;
    else
        h1(k+sum_gamma+1)=0;
    end

    if k==0 % 修正卷积核
        h(k+sum_gamma+1)=h1(k+sum_gamma+1)/2;
    else
        h(k+sum_gamma+1)=h1(k+sum_gamma+1)/2*(k*per_gamma/sin(k*per_gamma))^2;
    end
end
subplot(2,2,4);
plot(-sum_gamma:sum_gamma,h,'b')


% 反投影

rproj=zeros(n);
for i=1:n
    for j=1:n
        
        sum_pro=0;%积分初始值为0
        
        %第一步，计算图像点坐标
        x=i*2/n-1;
        y=j*2/n-1;
        
        %第二步，转换成极坐标
        r=sqrt(x^2+y^2);
        if x==0 && y==0
            theta=0;
        elseif x>0
            theta=asin(y/r);
            if theta<0
                theta=2*pi+theta;
            end
        else
            theta=pi-asin(y/r);
        end
        
        for k=1:sum_beta %角度从0度到359度
             
            beta=(k-1)*per_beta;

            L=sqrt(D^2+r^2+2*D*r*sin(beta-theta));
            gamma0=asin(r*cos(theta-beta)/L);
            
            %第四步，计算最接近的采样点（不同采样点对应不同的方向）
            num=gamma0/per_gamma+sum_gamma/2;% gamma=delta_gamma*(k-point_size/2-1/2)的逆运算
            
            num1=floor(num);%最接近的采样点（较小的点）
            
            if num1<=0
                num1=1;
            else
                if num1>=sum_gamma
                    num1=sum_gamma-1;
                end
            end
            
            num2=num1+1;%最接近的采样点（较大的点）
            
            gamma1=(num1-sum_gamma/2)*per_gamma;
            gamma2=(num2-sum_gamma/2)*per_gamma;
            
            %第五步，计算卷积(对gamma积分)
            
            temp_conv1=0;
            temp_conv2=0;
            conv_1=0;
            conv_2=0;
            for m=1:sum_gamma
                temp_conv1=temp_conv1+ pro(k,m)*D*cos(gamma1) * h(num1-m+1+sum_gamma);%g为偶函数
                temp_conv2=temp_conv2+ pro(k,m)*D*cos(gamma2) * h(num1-m+1+sum_gamma);
            end
            conv_1=temp_conv1*per_gamma;
            conv_2=temp_conv2*per_gamma;            
            %第六步，对2个卷积结果插值
            conv=conv_1*(num2-num)+conv_2*(num-num1);
            sum_pro=sum_pro+conv/L;
            
        end
        
        
        %得到积分结果
        rproj(n-j+1,i)=sum_pro*(2*pi/sum_beta);
            
    end
end

subplot(2,2,3);
imshow(rproj,[]);