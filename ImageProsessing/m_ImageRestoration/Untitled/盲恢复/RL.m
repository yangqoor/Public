function [res_image_RL,mse_RL]=RL(original,blured,OTF,iterations,denoise,project)
%Time：改动：2009.12.25   21:37
%--------------------------------------------------------------------------
%修改了降噪能力，将降噪以后的图像作为超分辨之前的blured图像。结果：性能有改进
%--------------------------------------------------------------------------
%基于RL算法的图像超分辨算法
%original,blured分别表示原始图像和退化图像矩阵，OTF为光传递函数，iterations是迭
%代次数，输出分别是复原图像res_image_RL和迭代过程中均方误差mse_RL的变化曲线
%--------------------------------------------------------------------------
%简单的初始化和数据矩阵预定义
mse_RL=zeros(1,iterations+1);
front=zeros(size(blured));%用来存放迭代以前的图像
back=front; %用来存放迭代以后的图像
%%% front=blured;    此处为12.25改
mse_RL(1)=MSE(original,blured);

win0=double(abs(OTF)<=1e-10);%找出OTF中全为零的
win1=1-win0;%找出OTF中不为零的点
%--------------------------------------------------------------------------
%是否选择降噪功能，是  denoise==1
if denoise==1
   G=fft2(blured).*win1;
   blured=IMRA(ifft2(G));%%%%%此处为12.25改
end
front=blured;

%是否投影                     %project==1表示要进行投影运算
if project==1
    %----------------------------------------------------------------------
    %维纳滤波
    %snr=estsnr(blured);
    %r=5*10^(-snr/10);  
    G1=fft2(front).*conj(OTF)./(abs(OTF).^2+0.01);%维纳滤波器复原图像的低频成分
    %G1=fft2(front)./(OTF+eps);%直接逆滤波进行低频恢复
    %G1=fft2(original);%试用理想图像的低频信息作实验
    
end

for i=1:iterations
    f1=fft2(front).*OTF;
    t2=IMRA(ifft2(f1));
    t3=blured./t2;
    f4=fft2(t3).*conj(OTF);
    t5=IMRA(ifft2(f4));
    back=front.*t5;
    %----------------------------------------------------------------------
    %project onto convex set
    %频域反复跟新
    if project==1
        %fback=win1.*G1+win0.*fft2(back);
        fback=OTF.*G1+(1-OTF).*fft2(back);
        back=IMRA(ifft2(fback));
        
    end
    %----------------------------------------------------------------------
    front=back;
    mse_RL(i+1)=MSE(original,front);
end
res_image_RL=front;
