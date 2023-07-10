%雷达目标有效散射面积
function rcs=qfmx(rcs_k,rcs0)
%% 输入变量
%rcs0    目标的平均截面积
%rcs_k        目标的起伏类型
%% 输出变量
%rcs       目标的散射面积
%% 程序
if rcs_k==0 
    rcs=rcs0;  %rcs_k =0时采用不起伏模型
elseif rcs_k==1
    rcs=-rcs0*log(1-rand(1,1));  %rcs_k =1时采用斯威林Ⅰ,Ⅱ起伏模型
elseif rcs_k==2
    rcs=-(rcs0/2)*(log(1-rand(1,1))+log(1-rand(1,1))); %rcs_k =2时采用斯威林Ⅲ,Ⅳ起伏模型
end