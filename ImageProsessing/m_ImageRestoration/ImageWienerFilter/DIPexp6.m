% DIP experiment 6
% 逆滤波,维纳滤波

clear all;

A = imread('lena.bmp');
figure(1),subplot(221);imshow(A,[]);title('原图像');
figure(2),subplot(221);imshow(A,[]);title('原图像');
figure(3),subplot(221);imshow(A,[]);title('原图像');
A = double(A);
[M,N] = size(A);

%产生模糊冲击函数的模板,其中n为模板的大小
n = 7;
h = BlurTemplate(n);
sumh = sum(sum(h));
h = h/sumh;

%为了消除混叠效应引起的误差，需要对模板H及原图像的尺寸进行延拓
%对模板尺寸进行延拓
expandh = zeros(M+n,N+n);
expandh(1:n, 1:n) = h; 
%对图像尺寸进行延拓
expandA = zeros(M+n,N+n);
expandA(1:M, 1:N) = A; 


%在频域对图像进行模糊
%对延拓后的expandH进行离散傅立叶变换，为了提高运算效率，故调用matlab中自带的fft2函数
FH = fft2(expandh);
%对延拓后的图像进行离散傅立叶变换
FA = fft2(expandA);
%退化操作
FbA = FA .* FH;
%进行傅立叶反变换得到退化后的模糊图像
bA = abs(ifft2(FbA));
% figure(4),imshow(bA(1+ceil(n/2):M+floor(n/2),1+ceil(n/2):N+floor(n/2)),[]);
% title('与冲击函数卷积模糊后的图像')


%对模糊后的图像叠加高斯噪声
nbA1 = bA + sqrt(8)*randn([M+n,N+n]);%叠加均值为0，方差为8的高斯随机噪声
nbA2 = bA + sqrt(16)*randn([M+n,N+n]);%叠加均值为0，方差为16的高斯随机噪声
nbA3 = bA + sqrt(32)*randn([M+n,N+n]);%叠加均值为0，方差为32的高斯随机噪声

%画出模糊并添加高斯噪声后的的图像
figure(1),subplot(222);imshow(nbA1(1+ceil(n/2):M+floor(n/2),1+ceil(n/2):N+floor(n/2)),[]);title('模糊并添加均值为8高斯噪声后的图像');
figure(2),subplot(222);imshow(nbA2(1+ceil(n/2):M+floor(n/2),1+ceil(n/2):N+floor(n/2)),[]);title('模糊并添加均值为16高斯噪声后的图像');
figure(3),subplot(222);imshow(nbA3(1+ceil(n/2):M+floor(n/2),1+ceil(n/2):N+floor(n/2)),[]);title('模糊并添加均值为32高斯噪声后的图像');

%对模糊并添加噪声后的图像求离散傅立叶变换
FnbA1 = fft2(nbA1);
FnbA2 = fft2(nbA2);
FnbA3 = fft2(nbA3);

%********************************逆滤波********************************

%为了防止H(u,v)在UV平面上取0或很小且消除振铃效应，取恢复转移函数FrH(u,v)为
% 如果  H(u,v)<d,   FrH(u,v)=k
%       H(u,v)>=d,  FrH(u,v)=1/H(u,v)
% 其中d为小于1的常数，且选的较小为好
FrH = zeros(M+n,N+n);
for i = 1:M+n
    for j = 1:N+n
        if abs(FH(i,j)) < 0.1
            FrH(i,j) = 1;
        else
            FrH(i,j) = 1/FH(i,j);
        end
    end
end
%逆滤波过程
FrnbA1 = FnbA1 .* FrH;
FrnbA2 = FnbA2 .* FrH;
FrnbA3 = FnbA3 .* FrH;
%得到逆滤波复原后的图像
rnbA1 = abs(ifft2(FrnbA1));
rnbA2 = abs(ifft2(FrnbA2));
rnbA3 = abs(ifft2(FrnbA3));
%画出逆滤波复原后的图像
figure(1),subplot(223);imshow(rnbA1(1:M,1:N),[]);title('逆滤波复原的图像');
figure(2),subplot(223);imshow(rnbA2(1:M,1:N),[]);title('逆滤波复原的图像');
figure(3),subplot(223);imshow(rnbA3(1:M,1:N),[]);title('逆滤波复原的图像');


%***********************************维纳滤波**************************************

%为求得噪声的功率谱对噪声进行离散傅立叶变换
Fn1 = fft2(nbA1 - bA);
Fn2 = fft2(nbA2 - bA);
Fn3 = fft2(nbA3 - bA);
%求得维纳滤波器转移函数
W1 = conj(FH) ./ abs( FH.*conj(FH) + (Fn1.*conj(Fn1)) ./ (FA.*conj(FA)) );
W2 = conj(FH) ./ abs( FH.*conj(FH) + (Fn2.*conj(Fn2)) ./ (FA.*conj(FA)) );
W3 = conj(FH) ./ abs( FH.*conj(FH) + (Fn3.*conj(Fn3)) ./ (FA.*conj(FA)) );
%维纳滤波过程
FwrnbA1 =  FnbA1 .* W1;
FwrnbA2 =  FnbA2 .* W2;
FwrnbA3 =  FnbA3 .* W3;
%求得维纳滤波复原后的图像
wrnbA1 = abs(ifft2(FwrnbA1));
wrnbA2 = abs(ifft2(FwrnbA2));
wrnbA3 = abs(ifft2(FwrnbA3));
%画出维纳滤波复原后的图像
figure(1),subplot(224);imshow(wrnbA1(1:M,1:N),[]);title('维纳滤波复原的图像');
figure(2),subplot(224);imshow(wrnbA2(1:M,1:N),[]);title('维纳滤波复原的图像');
figure(3),subplot(224);imshow(wrnbA3(1:M,1:N),[]);title('维纳滤波复原的图像');

