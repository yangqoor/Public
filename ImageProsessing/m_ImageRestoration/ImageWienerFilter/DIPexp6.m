% DIP experiment 6
% ���˲�,ά���˲�

clear all;

A = imread('lena.bmp');
figure(1),subplot(221);imshow(A,[]);title('ԭͼ��');
figure(2),subplot(221);imshow(A,[]);title('ԭͼ��');
figure(3),subplot(221);imshow(A,[]);title('ԭͼ��');
A = double(A);
[M,N] = size(A);

%����ģ�����������ģ��,����nΪģ��Ĵ�С
n = 7;
h = BlurTemplate(n);
sumh = sum(sum(h));
h = h/sumh;

%Ϊ���������ЧӦ���������Ҫ��ģ��H��ԭͼ��ĳߴ��������
%��ģ��ߴ��������
expandh = zeros(M+n,N+n);
expandh(1:n, 1:n) = h; 
%��ͼ��ߴ��������
expandA = zeros(M+n,N+n);
expandA(1:M, 1:N) = A; 


%��Ƶ���ͼ�����ģ��
%�����غ��expandH������ɢ����Ҷ�任��Ϊ���������Ч�ʣ��ʵ���matlab���Դ���fft2����
FH = fft2(expandh);
%�����غ��ͼ�������ɢ����Ҷ�任
FA = fft2(expandA);
%�˻�����
FbA = FA .* FH;
%���и���Ҷ���任�õ��˻����ģ��ͼ��
bA = abs(ifft2(FbA));
% figure(4),imshow(bA(1+ceil(n/2):M+floor(n/2),1+ceil(n/2):N+floor(n/2)),[]);
% title('�����������ģ�����ͼ��')


%��ģ�����ͼ����Ӹ�˹����
nbA1 = bA + sqrt(8)*randn([M+n,N+n]);%���Ӿ�ֵΪ0������Ϊ8�ĸ�˹�������
nbA2 = bA + sqrt(16)*randn([M+n,N+n]);%���Ӿ�ֵΪ0������Ϊ16�ĸ�˹�������
nbA3 = bA + sqrt(32)*randn([M+n,N+n]);%���Ӿ�ֵΪ0������Ϊ32�ĸ�˹�������

%����ģ������Ӹ�˹������ĵ�ͼ��
figure(1),subplot(222);imshow(nbA1(1+ceil(n/2):M+floor(n/2),1+ceil(n/2):N+floor(n/2)),[]);title('ģ������Ӿ�ֵΪ8��˹�������ͼ��');
figure(2),subplot(222);imshow(nbA2(1+ceil(n/2):M+floor(n/2),1+ceil(n/2):N+floor(n/2)),[]);title('ģ������Ӿ�ֵΪ16��˹�������ͼ��');
figure(3),subplot(222);imshow(nbA3(1+ceil(n/2):M+floor(n/2),1+ceil(n/2):N+floor(n/2)),[]);title('ģ������Ӿ�ֵΪ32��˹�������ͼ��');

%��ģ��������������ͼ������ɢ����Ҷ�任
FnbA1 = fft2(nbA1);
FnbA2 = fft2(nbA2);
FnbA3 = fft2(nbA3);

%********************************���˲�********************************

%Ϊ�˷�ֹH(u,v)��UVƽ����ȡ0���С����������ЧӦ��ȡ�ָ�ת�ƺ���FrH(u,v)Ϊ
% ���  H(u,v)<d,   FrH(u,v)=k
%       H(u,v)>=d,  FrH(u,v)=1/H(u,v)
% ����dΪС��1�ĳ�������ѡ�Ľ�СΪ��
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
%���˲�����
FrnbA1 = FnbA1 .* FrH;
FrnbA2 = FnbA2 .* FrH;
FrnbA3 = FnbA3 .* FrH;
%�õ����˲���ԭ���ͼ��
rnbA1 = abs(ifft2(FrnbA1));
rnbA2 = abs(ifft2(FrnbA2));
rnbA3 = abs(ifft2(FrnbA3));
%�������˲���ԭ���ͼ��
figure(1),subplot(223);imshow(rnbA1(1:M,1:N),[]);title('���˲���ԭ��ͼ��');
figure(2),subplot(223);imshow(rnbA2(1:M,1:N),[]);title('���˲���ԭ��ͼ��');
figure(3),subplot(223);imshow(rnbA3(1:M,1:N),[]);title('���˲���ԭ��ͼ��');


%***********************************ά���˲�**************************************

%Ϊ��������Ĺ����׶�����������ɢ����Ҷ�任
Fn1 = fft2(nbA1 - bA);
Fn2 = fft2(nbA2 - bA);
Fn3 = fft2(nbA3 - bA);
%���ά���˲���ת�ƺ���
W1 = conj(FH) ./ abs( FH.*conj(FH) + (Fn1.*conj(Fn1)) ./ (FA.*conj(FA)) );
W2 = conj(FH) ./ abs( FH.*conj(FH) + (Fn2.*conj(Fn2)) ./ (FA.*conj(FA)) );
W3 = conj(FH) ./ abs( FH.*conj(FH) + (Fn3.*conj(Fn3)) ./ (FA.*conj(FA)) );
%ά���˲�����
FwrnbA1 =  FnbA1 .* W1;
FwrnbA2 =  FnbA2 .* W2;
FwrnbA3 =  FnbA3 .* W3;
%���ά���˲���ԭ���ͼ��
wrnbA1 = abs(ifft2(FwrnbA1));
wrnbA2 = abs(ifft2(FwrnbA2));
wrnbA3 = abs(ifft2(FwrnbA3));
%����ά���˲���ԭ���ͼ��
figure(1),subplot(224);imshow(wrnbA1(1:M,1:N),[]);title('ά���˲���ԭ��ͼ��');
figure(2),subplot(224);imshow(wrnbA2(1:M,1:N),[]);title('ά���˲���ԭ��ͼ��');
figure(3),subplot(224);imshow(wrnbA3(1:M,1:N),[]);title('ά���˲���ԭ��ͼ��');

