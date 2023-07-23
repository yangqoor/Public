% ����ä�����ͼ��ָ� iterational blind deconvolution
clear all,close all,clc;
warning off
imgColor = imread('HW4.tif');
img = im2double(rgb2gray(imgColor));
figure,imshow(img),title('ģ��ͼ��');
area = prod(size(img));

size_psf = 15;
wpsf = zeros(size(img));
wpsf(1:size_psf,1:size_psf) = 1; % PSF֧����

iterTime = 20;
fw = img; % ͼ���ֵ
beta = .8; % ��������
noiseLevel = 1;
C = fft2(img);
Gw = zeros(size(C)); % PSFƵ�׳�ֵ

for p = 1:iterTime
	Fw = fft2(fw);
	G = getEstimateSpec(C,Fw,Gw,beta,noiseLevel); % �õ��µ�PSFƵ�׹���ֵ
	g = real(ifft2(G));
	gw = g; gw(gw < 0) = 0; % ����Լ��
	gw = gw.*wpsf; % ֧����
	gw = gw/sum(gw(:)); % ����Լ��
	Gw = fft2(gw);
	
	F = getEstimateSpec(C,Gw,Fw,beta,noiseLevel);
	f = real(ifft2(F));
	fw = f; fw(fw < 0) = 0;
	E = sum(abs(fw(:)-f(:)));
	fw = fw+E/area; % ��������
end

figure,imshow(fw),title('�ָ�ͼ��');
img(img == 0) = 1; % ��ֹ����Ϊ0
for p = 1:3
	fwColor(:,:,p) = im2double(imgColor(:,:,p)).*(fw./img); % ��ɫ�ָ�ͼ�����
end
figure,imshow(imgColor),title('ģ����ɫͼ��');
figure,imshow(fwColor),title('�ָ���ɫͼ��');

figure,surf(gw(1:size_psf,1:size_psf)),title('PSF����');
figure,imshow(fftshift(abs(Gw))),title('PSFƵ��');