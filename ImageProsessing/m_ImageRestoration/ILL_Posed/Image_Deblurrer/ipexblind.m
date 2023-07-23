
%% Deblurring Images Using the Blind Deconvolution Algorithm 
%%ä������㷨��ԭͼ��
% The Blind Deconvolution Algorithm can be used effectively when no
% information about the distortion (blurring and noise) is known. The
% algorithm restores the image and the point-spread function (PSF)
% simultaneously. The accelerated, damped Richardson-Lucy algorithm is used
% in each iteration. Additional optical system (e.g. camera)
% characteristics can be used as input parameters that could help to
% improve the quality of the image restoration. PSF constraints can be
% passed in through a user-specified function
%�ڲ�֪��ͼ��ʧ����Ϣ(ģ��������)��Ϣ����£�ä������㷨������Ч�ؼ������á����㷨
%��ͼ��͵���չ������PSF����ͬʱ���и�ԭ��ÿ�ε�����ʹ�ü�������Richardson-Lucy 
%�㷨������Ĺ�ѧϵͳ����������������Կ���Ϊ�����������������ͼ��ԭ����������ͨ
%���û�ָ���ĺ�����PSF��������
% Copyright 2004-2005 The MathWorks, Inc.
 
%% Step 1: Read Image
%%��һ������ȡͼ��
% The example reads in an intensity image. The |deconvblind| function can
% handle arrays of any dimension.
%��ʾ����ȡһ���Ҷ�ͼ��| deconvblind |�������Դ����κ�ά���顣
clc;clear;close all
I = imread('cameraman.tif');
figure;imshow(I);title('Original Image');
text(size(I,2),size(I,1)+15, ...
    'Image courtesy of Massachusetts Institute of Technology', ...
'FontSize',7,'HorizontalAlignment','right');  
   

 
%% Step 2: Simulate a Blur
%%�ڶ�����ģ��һ��ģ��
% Simulate a real-life image that could be blurred (e.g., due to camera
% motion or lack of focus). The example simulates the blur by convolving a
% Gaussian filter with the true image (using |imfilter|). The Gaussian filter
% then represents a point-spread function, |PSF|.
 %ģ��һ����ʵ�д��ڵ�ģ��ͼ�����磬�������������Խ����㣩���������ͨ������ʵ
%ͼ����и�˹�˲���ģ��ͼ��ģ����ʹ��|imfilter|������˹�˲�����һ������չ������
%|PSF|��
PSF=fspecial('gaussian',7,10);
Blurred=imfilter(I,PSF,'symmetric','conv');  %��ͼ��I�����˲�����
figure;imshow(Blurred);title('Blurred Image');  

   

 
%% Step 3: Restore the Blurred Image Using PSFs of Various Sizes
%%��������ʹ�ò�ͬ�ĵ���չ������ԭģ��ͼ��
% To illustrate the importance of knowing the size of the true PSF, this
% example performs three restorations. Each time the PSF reconstruction
% starts from a uniform array--an array of ones.
%Ϊ��˵��֪����ʵPSF�Ĵ�С����Ҫ�ԣ��������ִ�������޸���PSF�����ؽ�ÿ�ζ��Ǵ�ͳһ
%��ȫһ���鿪ʼ��
%%
% The first restoration, |J1| and |P1|, uses an undersized array, |UNDERPSF|, for
% an initial guess of the PSF. The size of the UNDERPSF array is 4 pixels
% shorter in each dimension than the true PSF. 
%��һ�θ�ԭ��|J1|��|P1|��ʹ��һ����С���飬| UNDERPSF |������PSF�ĳ����²⡣��
%UNDERPSF����ÿά����ʵPSF��4��Ԫ�ء�
UNDERPSF = ones(size(PSF)-4);
[J1 P1] = deconvblind(Blurred,UNDERPSF);
figure;imshow(J1);title('Deblurring with Undersized PSF'); 

   

%%
% The second restoration, |J2| and |P2|, uses an array of ones, |OVERPSF|, for an
% initial PSF that is 4 pixels longer in each dimension than the true PSF.
%�ڶ��θ�ԭ��|J2|��|P2|��ʹ��һ��Ԫ��ȫΪ1�����飬| OVERPSF|����ʼPSFÿά����
%ʵPSF��4��Ԫ�ء�
OVERPSF = padarray(UNDERPSF,[4 4],'replicate','both');
[J2 P2] = deconvblind(Blurred,OVERPSF);
figure;imshow(J2);title('Deblurring with Oversized PSF');  
   

 
%%
% The third restoration, |J3| and |P3|, uses an array of ones, |INITPSF|, for an
% initial PSF that is exactly of the same size as the true PSF.
%�����θ�ԭ��|J3|��|P3|��ʹ��һ��ȫΪһ������| INITPSF |��Ϊ����PSF��ÿά������
%��PSF��ͬ��
INITPSF = padarray(UNDERPSF,[2 2],'replicate','both');
[J3 P3] = deconvblind(Blurred,INITPSF);
figure;imshow(J3);title('Deblurring with INITPSF');  

   

 
%% Step 4: Analyzing the Restored PSF
%%���Ĳ���������ԭ����PSF
% All three restorations also produce a PSF. The following pictures show
% how the analysis of the reconstructed PSF might help in guessing the
% right size for the initial PSF. In the true PSF, a Gaussian filter, the
% maximum values are at the center (white) and diminish at the borders (black).
%������������ԭҲ����PSF������ͼƬ��ʾ��PSF�ؽ���������ο��������ڲ²����PSF�Ĵ�
%С����������PSF�У���˹�˲��������ֵ�����ģ��ף������߽���ʧ���ڣ���
figure;
subplot(221);imshow(PSF,[],'InitialMagnification','fit');
title('True PSF');
subplot(222);imshow(P1,[],'InitialMagnification','fit');
title('Reconstructed Undersized PSF');
subplot(223);imshow(P2,[],'InitialMagnification','fit');
title('Reconstructed Oversized PSF');
subplot(224);imshow(P3,[],'InitialMagnification','fit');
title('Reconstructed true PSF');  

   

 
%% 
% The PSF reconstructed in the first restoration, |P1|, obviously does not
% fit into the constrained size. It has a strong signal variation at the
% borders. The corresponding image, |J1|, does not show any improved clarity
% vs. the blurred image,.
 %��һ�θ�ԭ��PSF��|P1|����Ȼ���ʺϴ�С�����ơ����ڱ߽���һ��ǿ�ҵı仯�źš�
%��Ӧ��ͼƬ|J1|����ģ��ͼ��|Blurred|��û�б��ֳ���������ߡ�
%%
% The PSF reconstructed in the second restoration, |P2|, becomes very smooth
% at the edges. This implies that the restoration can handle a PSF of a
% smaller size. The corresponding image, |J2|, shows some deblurring but it
% is strongly corrupted by the ringing.
 %�ڶ��θ�ԭ��PSF��|P2|����Ե��÷ǳ�ƽ��������ζ�Ÿ�ԭ���Դ���һ����ϸ�µ�
%PSF����Ӧ��ͼƬ|J2|���Ե������ˣ�����һЩ�����塱ǿ���ƻ���
%%
% Finally, the PSF reconstructed in the third restoration, |P3|, is somewhat
% intermediate between |P1| and |P2|. The array, |P3|, resembles the true PSF
% very well. The corresponding image, |J3|, shows significant improvement;
% however it is still corrupted by the ringing.
 %��󣬵����θ�ԭ��PSF��|P3|������|P1|��|P2|֮�䡣������|P3|���ǳ��ӽ���
%����PSF����Ӧ��ͼƬ��|J3|����ʾ�����Ÿ��ƣ�������Ȼ��һЩ�����塱�ƻ���


%% Step 5: Improving the Restoration
%%���岽������ͼ��ԭ
% The ringing in the restored image, |J3|, occurs along the areas of sharp
% intensity contrast in the image and along the image borders. This example
% shows how to reduce the ringing effect by specifying a weighting
% function. The algorithm weights each pixel according to the |WEIGHT| array
% while restoring the image and the PSF. In our example, we start by
% finding the "sharp" pixels using the edge function. By trial and error,
% we determine that a desirable threshold level is 0.3.
%�ڸ�ԭͼ��|J3|�ڲ��ҶȶԱ������ĵط���ͼ��߽綼�����ˡ����塱���������˵�������
%ͨ������һ����Ȩ����������ͼ���еġ����塱�����㷨���ڶ�ͼ���PSF���и�ԭʱ����ÿ��
%��Ԫ����|WEIGHT|������м�Ȩ���㡣�����ǵ����ӣ����Ǵ��ñ�Ե�������ҡ���������Ԫ
%��ʼ��ͨ���������飬����ȷ���������ֵΪ0.3��
WEIGHT = edge(I,'sobel',.3);  
 
%%
% To widen the area, we use |imdilate| and pass in a structuring element, |se|.
%Ϊ���ؿ���������ʹ��|imdilate|������һ���ṹԪ��|se|��
se = strel('disk',2);
WEIGHT = 1-double(imdilate(WEIGHT,se));  
 
%%
% The pixels close to the borders are also assigned the value 0.
%�ڱ߽總�����ص�ֵҲ������Ϊ0��
WEIGHT([1:3 end-[0:2]],:) = 0;
WEIGHT(:,[1:3 end-[0:2]]) = 0;
figure;imshow(WEIGHT);title('Weight array');  

   

 %%
% The image is restored by calling deconvblind with the |WEIGHT| array and an
% increased number of iterations (30). Almost all the ringing is suppressed.
%��ͼ��ͨ��|WEIGHT|����������ظ�������30������deconvblind��������ԭ��������
%�еġ����塱�����ơ�
[J P] = deconvblind(Blurred,INITPSF,30,[],WEIGHT);
figure;imshow(J);title('Deblurred Image');  
   

 
%% Step 6: Using Additional Constraints on the PSF Restoration
%��������ʹ�ø���Լ����PSF��ԭ
% The example shows how you can specify additional constraints on the PSF.
%�������˵���������PSF��ָ����������ơ�
% The function, |FUN|, below returns a modified PSF array which deconvblind
% uses for the next iteration. 
%����|FUN|����һ���޸��˵�PSF���飬����deconvblind��������һ���ظ���
% In this example, |FUN| modifies the PSF by cropping it by |P1| and |P2| number
% of pixels in each dimension, and then padding the array back to its
% original size with zeros. This operation does not change the values in
% the center of the PSF, but effectively reduces the PSF size by |2*P1| and
% |2*P2| pixels. 
%����������У�ͨ����PSF�����ά������|P1|��|P2|��ֵʵ�ֶ�PSF���޸ģ����������
%���㡣�˲�������ı���PSF���ĵ�ֵ��������Ч���ڸ�ά������|2*P1|��| 2*P2|Ԫ
%�ء�
 
P1 = 2;
P2 = 2;
FUN = @(PSF) padarray(PSF(P1+1:end-P1,P2+1:end-P2),[P1 P2]);  
 
%%
% The anonymous function, |FUN|, is passed into |deconvblind| last.
%����������|FUN|����󴫵ݸ�| deconvblind |��
%%
% In this example, the size of the initial PSF, |OVERPSF|, is 4 pixels larger
% than the true PSF. Setting P1=2 and P2=2 as parameters in |FUN|
% effectively makes the valuable space in |OVERPSF| the same size as the true
% PSF. Therefore, the outcome, |JF| and |PF|, is similar to the result of
% deconvolution with the right sized PSF and no |FUN| call, |J| and |P|, from
% step 4.
%����������У���ʼPSF��|OVERPSF|��ÿά��������PSF��4�����أ�������P1=2��P2=2��
%Ϊ|FUN|�Ĳ���������Ч��ʹ|OVERPSF|��������PSF�Ĵ�С��ͬ����ˣ��õ��Ľ��|JF|
%��|PF|������Ĳ���ʹ��|FUN|��������ȷ�ߴ�PSFä������õ��Ľ��|J|��|P|���ơ�
[JF PF] = deconvblind(Blurred,OVERPSF,30,[],WEIGHT,FUN);
figure;imshow(JF);title('Deblurred Image');  

   

 
%%
% If we had used the oversized initial PSF, |OVERPSF|, without the
% constraining function, |FUN|, the resulting image would be similar to the
% unsatisfactory result, |J2|, achieved in Step 3.
%
% Note, that any unspecified parameters before |FUN| can be omitted, such as
% |DAMPAR| and |READOUT| in this example, without requiring a place holder,
% ([]).
 %�������ʹ����û��Լ���ĺ���|FUN|�Ľϴ�ĳ�ʼPSF��| OVERPSF |������ͼ����
%�Ƶ�3���õ���Ч�����������|J2|�� 
%ע�⣬�κ���|FUN|֮ǰδָ������������ʡ�ԣ���|DAMPAR|��|READOUT|����������У�������Ҫָʾ���ǵ�λ�ã�([])��
 
displayEndOfDemoMessage(mfilename) 
