function [  ] = Semivariance(  )
%计算影像经验半方差
%   此处显示详细说明
imgdata=imread('');
imgdata=double(imgdata);
w=size(imgdata,1);
h=size(imgdata,2);
layer=size(imgdata,3);
for i=1:layer
    k=floor(h/2);
    imgdata_t=imgdata(:,:,i);
    average=mean2(imgdata_t);
    for z=1:k
        t=z;
        a=imgdata_t;
        a(1:w-z,1:h)=imgdata_t(z+1:w,1:h);
        b=a-imgdata_t;
        c=b.*b;
        r1(t,i)=sum(sum(c));
        a=imgdata_t;
        a(1:w,1:h-z)=imgdata_t(1:w,z+1:h);
        b=a-imgdata_t;
        c=b.*b;
        r2(t,i)=sum(sum(c));
        a=imgdata_t;
        a(1:w-z,1:h-z)=imgdata_t(z+1:w,z+1:h);
        b=a-imgdata_t;
        c=b.*b;
        r3(t,i)=sum(sum(c));
        a=imgdata_t;
        c=b.*b;
        r4(t,i)=sum(sum(c));
        r(t,i)=(r1(t,i)+r2(t,i)+r3(t,i)+r4(t,i))/(2*(w*(h-z)+h*(w-z)+(w-z)*(h-z)+(w-z)*(h-z)))/(average*average);
    end
end
end


