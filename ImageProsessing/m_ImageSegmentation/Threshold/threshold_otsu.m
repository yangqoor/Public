f=dicomread('IM174');
f=im2double(f);
%ȫ����ֵ
T=0.5*(min(f(:))+max(f(:)));
done=false;
while ~done
    g=f>=T;
    Tn=0.5*(mean(f(g))+mean(f(~g)));
    done=abs(T-Tn)<0.1;
    T=Tn;
end
display('Treshold(T)-Iterative-������ֵ');%��ʾ����
T
r=im2bw(f,T);%ͼ��ڰ�ת��
figure,imshow(f,[]),title('����ͼ��');
figure,imshow(r);%��ʾ������ͼ��
title('������ȫ����ֵ�ָ�');
Th=graythresh(f);     %��ֵ
display('Threshold(T)-otsu''s method');
Th
s=im2bw(f,Th);
figure,imshow(s);
title('ȫ����ֵotsu�ָ');
se=strel('disk',10);
ft=imtophat(f,se);
Thr=graythresh(ft);
display('Threshold(T)-local Thresholding');
Thr
lt=im2bw(ft,Thr);
figure,imshow(lt);
title('�ֲ���ֵ�ָ�');