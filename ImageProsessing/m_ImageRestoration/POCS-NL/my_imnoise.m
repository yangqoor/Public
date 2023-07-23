% 产生人工噪声，类型1为均匀噪声
%v: 方差
%im:无噪声图像
%imn:im with noise

%type:
      %1:'unit'
      %2:'gaussian'
      %3:拟高斯信号
function imn=my_imnoise(v,im,type);
if type==1
    noise=rand(size(im))-0.5    ;
    noise=sqrt(v/var(noise(:)))*noise;
    imn=noise;
end

if type==2
    noise=randn(size(im));
    noise=sqrt(v/var(noise(:)))*noise;
    imn=noise;
end


      