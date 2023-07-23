I = checkerboard(8);%ԭͼ��
noise = 0.1*randn(size(I));%����
PSF = fspecial('motion',21,11);%�˶�ģ�����˲���
Blurred = imfilter(I,PSF,'circular');%�����˶�ģ����ͼ��
BlurredNoisy = im2uint8(Blurred + noise);%�˶�ģ����ͼ���������
NSR = sum(noise(:).^2)/sum(I(:).^2);%�����źŹ��ʱ�
NP = abs(fftn(noise)).^2; 
NPOW = sum(NP(:))/prod(size(noise));%����������
NCORR = fftshift(real(ifftn(NP))); %��������غ���
IP = abs(fftn(I)).^2;%
IPOW = sum(IP(:))/prod(size(I));%ԭͼ������
ICORR = fftshift(real(ifftn(IP)));%ԭͼ����غ���
ICORR1 = ICORR(:,ceil(size(I,1)/2));
NSR = NPOW/IPOW;%�����źŹ��ʱ�
J1=deconvwnr(BlurredNoisy,PSF);%���θı������������ά���˲�
J2=deconvwnr(BlurredNoisy,PSF,NSR);
J3=deconvwnr(BlurredNoisy,PSF,NCORR,ICORR);
J4=deconvwnr(BlurredNoisy,PSF,NPOW,ICORR1);
figure,%��ʾԭͼ���˻���ͼ���ά���˲����ͼ��
subplot(321), imshow(I); title('original image');
subplot(322); imshow(BlurredNoisy,[]); 
title('A = Blurred and Noisy');
subplot(323), imshow(J1,[]); title('deconvwnr(BlurredNoisy,PSF)');
subplot(324);imshow(J2,[]); title('deconvwnr(A,PSF,NSR)');
subplot(325);imshow(J3,[]); title('deconvwnr(A,PSF,NCORR,ICORR)');
subplot(326);imshow(J4,[]); title('deconvwnr(A,PSF,NPOW,ICORR_1_D)');
