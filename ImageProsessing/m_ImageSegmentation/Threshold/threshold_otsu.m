f=dicomread('IM174');
f=im2double(f);
%全局阈值
T=0.5*(min(f(:))+max(f(:)));
done=false;
while ~done
    g=f>=T;
    Tn=0.5*(mean(f(g))+mean(f(~g)));
    done=abs(T-Tn)<0.1;
    T=Tn;
end
display('Treshold(T)-Iterative-迭代阈值');%显示文字
T
r=im2bw(f,T);%图像黑白转换
figure,imshow(f,[]),title('乳腺图像');
figure,imshow(r);%显示处理后的图像
title('迭代法全局阈值分割');
Th=graythresh(f);     %阈值
display('Threshold(T)-otsu''s method');
Th
s=im2bw(f,Th);
figure,imshow(s);
title('全局阈值otsu分割法');
se=strel('disk',10);
ft=imtophat(f,se);
Thr=graythresh(ft);
display('Threshold(T)-local Thresholding');
Thr
lt=im2bw(ft,Thr);
figure,imshow(lt);
title('局部阈值分割');